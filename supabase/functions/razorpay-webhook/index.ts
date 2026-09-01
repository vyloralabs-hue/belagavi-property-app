// Supabase Edge Function: razorpay-webhook
// Secure, idempotent webhook endpoint processing asynchronous Razorpay events

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";
import { hmac } from "https://deno.land/x/hmac@v2.0.1/mod.ts";

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  try {
    const webhookSignature = req.headers.get("x-razorpay-signature");
    if (!webhookSignature) {
      return new Response(JSON.stringify({ error: "Missing x-razorpay-signature header" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const rawBody = await req.text();
    const webhookSecret = Deno.env.get("RAZORPAY_WEBHOOK_SECRET") ?? "";
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    // 1. Verify Webhook Signature using HMAC-SHA256 over raw body
    if (webhookSecret) {
      const expectedSignature = hmac("sha256", webhookSecret, rawBody, "utf8", "hex");
      if (expectedSignature !== webhookSignature) {
        return new Response(JSON.stringify({ error: "Invalid webhook signature" }), {
          status: 400,
          headers: { "Content-Type": "application/json" },
        });
      }
    }

    const payload = JSON.parse(rawBody);
    const eventId = payload.event_id || req.headers.get("x-razorpay-event-id") || `evt_${Date.now()}`;
    const eventType = payload.event;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 2. Idempotency Check: Prevent duplicate event processing
    const { data: existingEvent } = await supabase
      .from("webhook_events")
      .select("event_id, processed")
      .eq("event_id", eventId)
      .maybeSingle();

    if (existingEvent && existingEvent.processed) {
      // Event already processed previously, return 200 OK immediately
      return new Response(JSON.stringify({ status: "already_processed" }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    const paymentEntity = payload.payload?.payment?.entity;
    const orderEntity = payload.payload?.order?.entity;
    const orderId = paymentEntity?.order_id || orderEntity?.id;
    const paymentId = paymentEntity?.id;

    // 3. Canonical Fulfillment Path for Successful Payment Events
    if (eventType === "payment.captured" || eventType === "order.paid") {
      if (orderId && paymentId) {
        // Execute atomic activation RPC
        await supabase.rpc("fn_authoritative_grant_entitlement_and_promotion", {
          p_order_id: orderId,
          p_payment_id: paymentId,
          p_signature: webhookSignature,
          p_actor_id: "razorpay_webhook",
        });
      }
    } else if (eventType === "payment.failed") {
      if (orderId) {
        // Lock and update order to failed only if not already captured
        const { data: currentOrder } = await supabase
          .from("payment_orders")
          .select("status")
          .eq("order_id", orderId)
          .single();

        if (currentOrder && currentOrder.status !== "captured") {
          await supabase
            .from("payment_orders")
            .update({ status: "failed", updated_at: new Date().toISOString() })
            .eq("order_id", orderId);
        }
      }
    }

    // 4. Record event in webhook_events ledger
    await supabase
      .from("webhook_events")
      .upsert({
        event_id: eventId,
        provider: "razorpay",
        event_type: eventType,
        order_id: orderId,
        payment_id: paymentId,
        payload: payload,
        processed: true,
      });

    return new Response(JSON.stringify({ status: "success", eventId: eventId }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
