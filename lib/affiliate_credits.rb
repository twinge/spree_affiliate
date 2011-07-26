module AffiliateCredits
  private

  def create_affiliate_credits(sender, recipient, event, order = nil)
    #check if sender should receive credit on affiliate register
    if sender_credit_amount = Spree::Config["sender_credit_on_#{event}_amount".to_sym] and sender_credit_amount.to_f > 0
      if order
        sender_credit_amount = order.item_total * (sender_credit_amount.to_f / 100.0)
      end
      credit = StoreCredit.create(:amount => sender_credit_amount,
                         :remaining_amount => sender_credit_amount,
                         :reason => "Affiliate: #{event}", :user => sender)

      log_event recipient.affiliate_partner, sender, credit, event
    end

    #check if affiliate should recevied credit on sign up
    if recipient_credit_amount = Spree::Config["recipient_credit_on_#{event}_amount".to_sym] and recipient_credit_amount.to_f > 0
      credit = StoreCredit.create(:amount => recipient_credit_amount,
                         :remaining_amount => recipient_credit_amount,
                         :reason => "Affiliate: #{event}", :user => recipient)

      log_event recipient.affiliate_partner, recipient, credit, event
    end

  end

  def log_event(affiliate, user, credit, event)
    affiliate.events.create(:reward => credit, :name => event, :user => user)
  end

end
