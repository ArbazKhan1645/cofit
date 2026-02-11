-- ============================================
-- Support Tickets & Messages
-- ============================================

-- Support tickets table
CREATE TABLE IF NOT EXISTS public.support_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    subject TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    priority TEXT NOT NULL DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    screen_reference TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Ticket messages table
CREATE TABLE IF NOT EXISTS public.ticket_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID NOT NULL REFERENCES public.support_tickets(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    is_admin BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_support_tickets_user_id ON public.support_tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_support_tickets_status ON public.support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_support_tickets_created ON public.support_tickets(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ticket_messages_ticket_id ON public.ticket_messages(ticket_id);
CREATE INDEX IF NOT EXISTS idx_ticket_messages_created ON public.ticket_messages(created_at ASC);

-- ============================================
-- RLS Policies
-- ============================================

ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ticket_messages ENABLE ROW LEVEL SECURITY;

-- Users can view their own tickets
CREATE POLICY "Users can view own tickets"
    ON public.support_tickets FOR SELECT
    USING (auth.uid() = user_id);

-- Users can create tickets
CREATE POLICY "Users can create tickets"
    ON public.support_tickets FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Admin can view all tickets
CREATE POLICY "Admin can view all tickets"
    ON public.support_tickets FOR SELECT
    USING (public.is_admin());

-- Admin can update tickets
CREATE POLICY "Admin can update tickets"
    ON public.support_tickets FOR UPDATE
    USING (public.is_admin());

-- Admin can delete tickets
CREATE POLICY "Admin can delete tickets"
    ON public.support_tickets FOR DELETE
    USING (public.is_admin());

-- Users can view messages on their tickets
CREATE POLICY "Users can view own ticket messages"
    ON public.ticket_messages FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.support_tickets
            WHERE id = ticket_messages.ticket_id AND user_id = auth.uid()
        )
    );

-- Users can send messages on their tickets
CREATE POLICY "Users can send messages on own tickets"
    ON public.ticket_messages FOR INSERT
    WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM public.support_tickets
            WHERE id = ticket_messages.ticket_id AND user_id = auth.uid()
        )
    );

-- Admin can view all messages
CREATE POLICY "Admin can view all messages"
    ON public.ticket_messages FOR SELECT
    USING (public.is_admin());

-- Admin can send messages
CREATE POLICY "Admin can insert messages"
    ON public.ticket_messages FOR INSERT
    WITH CHECK (public.is_admin());

-- Admin can delete messages
CREATE POLICY "Admin can delete messages"
    ON public.ticket_messages FOR DELETE
    USING (public.is_admin());
