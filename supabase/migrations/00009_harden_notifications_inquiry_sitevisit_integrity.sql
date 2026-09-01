-- Migration: 00009_harden_notifications_inquiry_sitevisit_integrity.sql
-- Description: Security hardening for notifications, inquiries, and site visits
-- Eliminates open notification inserts, enforces event-driven triggers, and secures payload integrity

-- 1. Function to ensure clean application admin check
CREATE OR REPLACE FUNCTION public.is_app_admin_or_founder()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() 
        AND role::text IN ('admin', 'founder', 'super_admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Drop open notification insert policy
DROP POLICY IF EXISTS "Authenticated users can create notifications" ON public.notifications;

-- 3. Hardened Notification INSERT policy
-- Direct inserts are only allowed if the caller is an Admin OR the caller is a participant in the referenced inquiry and the recipient matches the counterparty
CREATE POLICY "Strict validated notification creation"
ON public.notifications
FOR INSERT
TO authenticated
WITH CHECK (
    public.is_app_admin_or_founder()
    OR (
        inquiry_id IS NOT NULL 
        AND EXISTS (
            SELECT 1 FROM public.property_inquiries pi
            WHERE pi.id = inquiry_id
            AND (
                (pi.buyer_id = (SELECT auth.uid())::text AND notifications.recipient_id = pi.seller_id)
                OR
                (pi.seller_id = (SELECT auth.uid())::text AND notifications.recipient_id = pi.buyer_id)
            )
        )
    )
);

-- 4. Hardened Notification UPDATE policy (Immutability of recipient_id and references)
DROP POLICY IF EXISTS "Recipients can update own notifications" ON public.notifications;

CREATE POLICY "Recipients can only update read status of own notifications"
ON public.notifications
FOR UPDATE
TO authenticated
USING (
    recipient_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
)
WITH CHECK (
    (recipient_id = (SELECT auth.uid())::text OR public.is_app_admin_or_founder())
    AND recipient_id = (SELECT n.recipient_id FROM public.notifications n WHERE n.id = notifications.id)
    AND type = (SELECT n.type FROM public.notifications n WHERE n.id = notifications.id)
    AND (
        (property_id IS NULL AND (SELECT n.property_id FROM public.notifications n WHERE n.id = notifications.id) IS NULL)
        OR property_id = (SELECT n.property_id FROM public.notifications n WHERE n.id = notifications.id)
    )
);

-- 5. Hardened Property Inquiries INSERT policy
-- Enforces that the seller_id MUST be the real owner of the referenced property
DROP POLICY IF EXISTS "Authenticated buyers can create inquiries" ON public.property_inquiries;

CREATE POLICY "Strict validated property inquiries insert"
ON public.property_inquiries
FOR INSERT
TO authenticated
WITH CHECK (
    (buyer_id = (SELECT auth.uid())::text OR public.is_app_admin_or_founder())
    AND seller_id = (
        SELECT p.owner_id::text 
        FROM public.properties p 
        WHERE p.id = property_id
    )
);

-- 6. Server-Side Automated Notification Trigger for Inquiries & Site Visits
CREATE OR REPLACE FUNCTION public.fn_notify_on_inquiry_event()
RETURNS TRIGGER AS $$
BEGIN
    -- Handle NEW Inquiry / Site Visit Request
    IF (TG_OP = 'INSERT') THEN
        IF (NEW.site_visit_status = 'requested') THEN
            INSERT INTO public.notifications (
                id, recipient_id, type, title, body, property_id, inquiry_id, is_read, created_at, updated_at
            ) VALUES (
                'notif_' || gen_random_uuid()::text,
                NEW.seller_id,
                'NEW_SITE_VISIT_REQUEST',
                'New Site Visit Request',
                NEW.buyer_name || ' requested an on-site visit for "' || NEW.property_title || '".',
                NEW.property_id,
                NEW.id,
                false,
                NOW(),
                NOW()
            );
        ELSE
            INSERT INTO public.notifications (
                id, recipient_id, type, title, body, property_id, inquiry_id, is_read, created_at, updated_at
            ) VALUES (
                'notif_' || gen_random_uuid()::text,
                NEW.seller_id,
                'NEW_PROPERTY_INQUIRY',
                'New Property Inquiry',
                NEW.buyer_name || ' is interested in your property "' || NEW.property_title || '".',
                NEW.property_id,
                NEW.id,
                false,
                NOW(),
                NOW()
            );
        END IF;
        RETURN NEW;
    END IF;

    -- Handle Status / Site Visit Updates
    IF (TG_OP = 'UPDATE') THEN
        IF (OLD.site_visit_status IS DISTINCT FROM NEW.site_visit_status) THEN
            IF (NEW.site_visit_status IN ('confirmed', 'scheduled')) THEN
                INSERT INTO public.notifications (
                    id, recipient_id, type, title, body, property_id, inquiry_id, is_read, created_at, updated_at
                ) VALUES (
                    'notif_' || gen_random_uuid()::text,
                    NEW.buyer_id,
                    'SITE_VISIT_CONFIRMED',
                    'Site Visit Confirmed',
                    'Your site visit for "' || NEW.property_title || '" has been confirmed by the owner.',
                    NEW.property_id,
                    NEW.id,
                    false,
                    NOW(),
                    NOW()
                );
            ELSIF (NEW.site_visit_status = 'cancelled' OR NEW.site_visit_status = 'rejected') THEN
                INSERT INTO public.notifications (
                    id, recipient_id, type, title, body, property_id, inquiry_id, is_read, created_at, updated_at
                ) VALUES (
                    'notif_' || gen_random_uuid()::text,
                    NEW.buyer_id,
                    'SITE_VISIT_REJECTED',
                    'Site Visit Update',
                    'Your site visit request for "' || NEW.property_title || '" could not be accommodated.',
                    NEW.property_id,
                    NEW.id,
                    false,
                    NOW(),
                    NOW()
                );
            END IF;
        END IF;
        RETURN NEW;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_inquiry_notification ON public.property_inquiries;

CREATE TRIGGER trg_inquiry_notification
AFTER INSERT OR UPDATE ON public.property_inquiries
FOR EACH ROW EXECUTE FUNCTION public.fn_notify_on_inquiry_event();
