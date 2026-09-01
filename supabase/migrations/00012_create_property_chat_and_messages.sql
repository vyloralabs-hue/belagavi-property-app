-- Migration: 00012_create_property_chat_and_messages.sql
-- Description: Create property_conversations and property_messages tables with strict participant RLS

-- 1. Create Property Conversations Table
CREATE TABLE IF NOT EXISTS public.property_conversations (
    id TEXT PRIMARY KEY,
    property_id TEXT NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    buyer_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    seller_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    last_message_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_message_preview TEXT,
    status TEXT NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_property_buyer_conversation UNIQUE(property_id, buyer_id)
);

CREATE INDEX IF NOT EXISTS idx_conv_buyer_id ON public.property_conversations(buyer_id);
CREATE INDEX IF NOT EXISTS idx_conv_seller_id ON public.property_conversations(seller_id);
CREATE INDEX IF NOT EXISTS idx_conv_property_id ON public.property_conversations(property_id);
CREATE INDEX IF NOT EXISTS idx_conv_last_message_at ON public.property_conversations(last_message_at DESC);

ALTER TABLE public.property_conversations ENABLE ROW LEVEL SECURITY;

-- Conversations RLS
CREATE POLICY "View own conversations"
ON public.property_conversations
FOR SELECT
TO authenticated
USING (
    buyer_id = (SELECT auth.uid())::text
    OR seller_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

CREATE POLICY "Insert conversation as buyer"
ON public.property_conversations
FOR INSERT
TO authenticated
WITH CHECK (
    buyer_id = (SELECT auth.uid())::text
    AND seller_id = (SELECT owner_id::text FROM public.properties WHERE id = property_id)
    AND (SELECT auth.uid())::text != seller_id
);

CREATE POLICY "Update own conversations"
ON public.property_conversations
FOR UPDATE
TO authenticated
USING (
    buyer_id = (SELECT auth.uid())::text
    OR seller_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
)
WITH CHECK (
    buyer_id = (SELECT auth.uid())::text
    OR seller_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

-- 2. Create Property Messages Table
CREATE TABLE IF NOT EXISTS public.property_messages (
    id TEXT PRIMARY KEY,
    conversation_id TEXT NOT NULL REFERENCES public.property_conversations(id) ON DELETE CASCADE,
    sender_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    message_type TEXT NOT NULL DEFAULT 'TEXT',
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_messages_conversation_created ON public.property_messages(conversation_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON public.property_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_unread ON public.property_messages(conversation_id, is_read) WHERE is_read = false;

ALTER TABLE public.property_messages ENABLE ROW LEVEL SECURITY;

-- Messages RLS
CREATE POLICY "View conversation messages"
ON public.property_messages
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.property_conversations c 
        WHERE c.id = property_messages.conversation_id 
        AND (
            c.buyer_id = (SELECT auth.uid())::text 
            OR c.seller_id = (SELECT auth.uid())::text 
            OR public.is_app_admin_or_founder()
        )
    )
);

CREATE POLICY "Insert message as participant"
ON public.property_messages
FOR INSERT
TO authenticated
WITH CHECK (
    sender_id = (SELECT auth.uid())::text
    AND EXISTS (
        SELECT 1 FROM public.property_conversations c 
        WHERE c.id = property_messages.conversation_id 
        AND (
            c.buyer_id = (SELECT auth.uid())::text 
            OR c.seller_id = (SELECT auth.uid())::text
        )
        AND c.status = 'ACTIVE'
    )
);

CREATE POLICY "Update message read status as participant"
ON public.property_messages
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.property_conversations c 
        WHERE c.id = property_messages.conversation_id 
        AND (
            c.buyer_id = (SELECT auth.uid())::text 
            OR c.seller_id = (SELECT auth.uid())::text
        )
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.property_conversations c 
        WHERE c.id = property_messages.conversation_id 
        AND (
            c.buyer_id = (SELECT auth.uid())::text 
            OR c.seller_id = (SELECT auth.uid())::text
        )
    )
);
