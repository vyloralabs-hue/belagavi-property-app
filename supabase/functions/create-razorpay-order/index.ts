// Supabase Edge Function: create-razorpay-order
// Handles server-authoritative, semantically idempotent Razorpay order creation

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";

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

    // Verify authenticated user
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized user session" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = await req.json();
    const { planId, productType, referenceEntityId, clientIntentKey } = body;

    if (!planId || !productType || !referenceEntityId) {
      return new Response(JSON.stringify({ error: "Missing required parameters (planId, productType, referenceEntityId)" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 1. Authoritative price lookup from DB (NEVER trust client amount)
    const { data: plan, error: planError } = await supabase
      .from("pricing_plans")
      .select("*")
      .eq("plan_id", planId)
      .eq("is_active", true)
      .single();

    if (planError || !plan) {
      return new Response(JSON.stringify({ error: `Pricing plan '${planId}' not found or inactive` }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. Ownership verification if product is a property
    if (productType === "property") {
      const { data: property, error: propError } = await supabase
        .from("properties")
        .select("owner_id, title, status")
        .eq("id", referenceEntityId)
        .single();

      if (propError || !property) {
        return new Response(JSON.stringify({ error: "Property listing not found" }), {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      if (property.owner_id !== user.id) {
        return new Response(JSON.stringify({ error: "Access denied: Cannot promote another user's property" }), {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      if (property.status === "archived" || property.status === "sold" || property.status === "rented") {
        return new Response(JSON.stringify({ error: `Cannot promote property in '${property.status}' status` }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    // 3. True Semantic Idempotency Check
    // Deterministic intent key derived from authenticated user, target entity, and selected plan
    const intentKey = clientIntentKey || `intent_${user.id}_${referenceEntityId}_${planId}`;

    const { data: existingOrders } = await supabase
      .from("payment_orders")
      .select("*")
      .eq("user_id", user.id)
      .eq("reference_entity_id", referenceEntityId)
      .eq("plan_id", planId)
      .order("created_at", { ascending: false })
      .limit(1);

    if (existingOrders && existingOrders.length > 0) {
      const existing = existingOrders[0];
      const createdAt = new Date(existing.created_at).getTime();
      const now = Date.now();
      const ageMinutes = (now - createdAt) / (1000 * 60);

      // If active pending/initiated order exists and is less than 30 mins old, reuse it
      if ((existing.status === "initiated" || existing.status === "pending") && ageMinutes < 30) {
        return new Response(
          JSON.stringify({
            success: true,
            orderId: existing.order_id,
            amountInPaise: Number(existing.amount_in_paise),
            currency: existing.currency,
            keyId: razorpayKeyId || "rzp_test_placeholder",
            planTitle: plan.plan_name,
            isReusedIntent: true,
          }),
          {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }

      // If already captured, inform caller
      if (existing.status === "captured") {
        return new Response(
          JSON.stringify({
            success: true,
            orderId: existing.order_id,
            amountInPaise: Number(existing.amount_in_paise),
            currency: existing.currency,
            keyId: razorpayKeyId || "rzp_test_placeholder",
            planTitle: plan.plan_name,
            alreadyCaptured: true,
          }),
          {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }
    }

    const amountInPaise = Number(plan.final_amount_in_paise);
    const receipt = `rcpt_${referenceEntityId.slice(0, 8)}_${Date.now().toString().slice(-6)}`;

    // 4. Call Razorpay API to create official order
    let razorpayOrderId = "";
    if (razorpayKeyId && razorpayKeySecret) {
      const authStr = btoa(`${razorpayKeyId}:${razorpayKeySecret}`);
      const rzpRes = await fetch("https://api.razorpay.com/v1/orders", {
        method: "POST",
        headers: {
          "Authorization": `Basic ${authStr}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          amount: amountInPaise,
          currency: plan.currency || "INR",
          receipt: receipt,
          notes: {
            user_id: user.id,
            plan_id: planId,
            product_type: productType,
            reference_entity_id: referenceEntityId,
            intent_key: intentKey,
          },
        }),
      });

      if (!rzpRes.ok) {
        const rzpErr = await rzpRes.text();
        return new Response(JSON.stringify({ error: `Razorpay API error: ${rzpErr}` }), {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const rzpData = await rzpRes.json();
      razorpayOrderId = rzpData.id;
    } else {
      // Test/offline environment fallback order generation
      razorpayOrderId = `order_rzp_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
    }

    // 5. Persist order record in payment_orders
    const uniqueIdempKey = `${intentKey}_${Date.now()}`;
    const { error: insertError } = await supabase
      .from("payment_orders")
      .insert({
        order_id: razorpayOrderId,
        user_id: user.id,
        plan_id: planId,
        product_type: productType,
        reference_entity_id: referenceEntityId,
        amount_in_paise: amountInPaise,
        currency: plan.currency || "INR",
        status: "initiated",
        idempotency_key: uniqueIdempKey,
      });

    if (insertError) {
      return new Response(JSON.stringify({ error: `Database order persistence error: ${insertError.message}` }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(
      JSON.stringify({
        success: true,
        orderId: razorpayOrderId,
        amountInPaise: amountInPaise,
        currency: plan.currency || "INR",
        keyId: razorpayKeyId || "rzp_test_placeholder",
        planTitle: plan.plan_name,
        isReusedIntent: false,
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
