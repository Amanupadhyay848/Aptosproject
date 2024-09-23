module MyModule::EventTicketing {

    use aptos_framework::signer;
    use std::vector;
    use aptos_framework::coin;
        use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing an event ticket.
    struct Ticket has store, key {
        event_name: vector<u8>,  // Name of the event
        ticket_price: u64,       // Price of the ticket
        available_tickets: u64,  // Number of tickets available
    }

    /// Function for an event organizer to create a new event and set ticket details.
    public fun create_event(organizer: &signer, event_name: vector<u8>, ticket_price: u64, available_tickets: u64) {
        let ticket = Ticket {
            event_name,
            ticket_price,
            available_tickets,
        };
        move_to(organizer, ticket);
    }

    /// Function for users to purchase tickets for the event.
    public fun purchase_ticket(buyer: &signer, organizer_address: address, num_tickets: u64) acquires Ticket {
        let ticket = borrow_global_mut<Ticket>(organizer_address);

        // Ensure there are enough tickets available
        assert!(ticket.available_tickets >= num_tickets, 1);

        // Calculate total cost and perform the payment
        let total_cost = ticket.ticket_price * num_tickets;
        let payment = coin::withdraw<AptosCoin>(buyer, total_cost);
        coin::deposit<AptosCoin>(organizer_address, payment);

        // Reduce the number of available tickets
        ticket.available_tickets = ticket.available_tickets - num_tickets;
    }
}
