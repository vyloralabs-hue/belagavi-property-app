// Supabase Edge Function: verify-razorpay-payment
// Cryptographically verifies Razorpay payment signatures (HMAC-SHA256), validates REST API payment state, and atomically activates entitlements

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";
import { hmac } from "https://deno.land/x/hmac@v2.0.1/mod.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization token" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const razorpayKeyId = Deno.env.get("RAZORPAY_KEY_ID") ?? "";
    const razorpayKeySecret = Deno.env.get("RAZORPAY_KEY_SECRET") ?? "";

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Verify user JWT
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized user session" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = await req.json();
    const { orderId, paymentId, signature } = body;

    if (!orderId || !paymentId || !signature) {
      return new Response(JSON.stringify({ error: "Missing verification parameters (orderId, paymentId, signature)" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 1. Fetch order record from database
    const { data: order, error: orderError } = await supabase
      .from("payment_orders")
      .select("*")
      .eq("order_id", orderId)
      .single();

    if (orderError || !order) {
      return new Response(JSON.stringify({ error: `Payment order '${orderId}' not found` }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Check user ownership of order
    if (order.user_id !== user.id) {
      return new Response(JSON.stringify({ error: "Access denied: Order does not belong to the authenticated user" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. Cryptographic HMAC-SHA256 Signature Verification
    if (razorpayKeySecret) {
      const payloadToSign = `${orderId}|${paymentId}`;
      const expectedSignature = hmac("sha256", razorpayKeySecret, payloadToSign, "utf8", "hex");

      if (expectedSignature !== signature) {
        // Record failed attempt in audit log
        await supabase.from("financial_audit_logs").insert({
          actor_id: user.id,
          actor_role: "user",
          action: "SIGNATURE_VERIFICATION_FAILED",
          entity_type: order.product_type,
          entity_id: order.reference_entity_id,
          previous_state: order.status,
          new_state: "failed",
          amount_in_paise: order.amount_in_paise,
          currency: order.currency,
          reason: `Invalid HMAC signature provided for payment ${paymentId}`,
        });

        return new Response(JSON.stringify({ error: "Invalid payment signature verification failed" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    // 3. Razorpay REST API Payment State Verification (Phase 2 & 3 Hardening)
    if (razorpayKeyId && razorpayKeySecret) {
      const authStr = btoa(`${razorpayKeyId}:${razorpayKeySecret}`);
      const rzpPayRes = await fetch(`https://api.razorpay.com/v1/payments/${paymentId}`, {
        method: "GET",
        headers: { "Authorization": `Basic ${authStr}` },
      });

      if (!rzpPayRes.ok) {
        const rzpPayErr = await rzpPayRes.text();
        return new Response(JSON.stringify({ error: `Razorpay payment verification API error: ${rzpPayErr}` }), {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const rzpPayment = await rzpPayRes.json();

      // Verify payment is bound to the exact server order
      if (rzpPayment.order_id !== orderId) {
        return new Response(JSON.stringify({ error: "Payment verification error: Payment ID is not associated with this Order ID" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      // Verify exact amount in paise match
      if (Number(rzpPayment.amount) !== Number(order.amount_in_paise)) {
        return new Response(JSON.stringify({ error: "Payment verification error: Payment amount does not match canonical order amount" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      // Verify currency match
      if (rzpPayment.currency !== order.currency) {
        return new Response(JSON.stringify({ error: "Payment verification error: Payment currency mismatch" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      // Verify / perform payment capture
      if (rzpPayment.status === "authorized") {
        const captureRes = await fetch(`https://api.razorpay.com/v1/payments/${paymentId}/capture`, {
          method: "POST",
          headers: {
            "Authorization": `Basic ${authStr}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ amount: order.amount_in_paise, currency: order.currency }),
        });

        if (!captureRes.ok) {
          const capErr = await captureRes.text();
          return new Response(JSON.stringify({ error: `Payment capture error: ${capErr}` }), {
            status: 502,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
        }
      } else if (rzpPayment.status !== "captured") {
        return new Response(JSON.stringify({ error: `Payment verification error: Payment is in uncaptured status '${rzpPayment.status}'` }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    // 4. Atomically activate entitlement, update order, and record transaction via DB RPC
    const { data: rpcResult, error: rpcError } = await supabase.rpc(
      "fn_authoritative_grant_entitlement_and_promotion",
      {
        p_order_id: orderId,
        p_payment_id: paymentId,
        p_signature: signature,
        p_actor_id: user.id,
      }
    );

    if (rpcError) {
      return new Response(JSON.stringify({ error: `Entitlement activation error: ${rpcError.message}` }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(
      JSON.stringify({
        success: true,
        orderId: orderId,
        paymentId: paymentId,
        status: "captured",
        activation: rpcResult,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
