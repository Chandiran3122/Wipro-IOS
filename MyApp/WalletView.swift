import SwiftUI

struct WalletView: View {
    @ObservedObject var store: DeliveryStore
    
    @State private var selectedFilter: String = "All"
    @State private var showCashoutSheet: Bool = false
    @State private var cashoutAmount: String = ""
    @State private var showSettleCodAlert: Bool = false
    @State private var showCommissionInfoSheet: Bool = false
    
    private let filterOptions = ["All", "Credits (+)", "Commission (-)", "Cashouts (-)"]
    
    var body: some View {
        ZStack {
            SwiggyColors.deepNavy
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("FINANCES & PAYOUTS")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(SwiggyColors.orange)
                            Text("Partner Wallet")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        
                        // Commission Info Quick Button
                        Button(action: {
                            showCommissionInfoSheet = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 12))
                                Text("Fee Rules")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(SwiggyColors.mutedText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(SwiggyColors.cardLight)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Main Digital Wallet Card
                    digitalWalletCard
                        .padding(.horizontal, 20)
                    
                    // Stats Row: Earnings, Swiggy Commission, Incentives
                    walletStatsRow
                        .padding(.horizontal, 20)
                    
                    // Swiggy Commission Banner (Taken by Swiggy)
                    swiggyCommissionBanner
                        .padding(.horizontal, 20)
                    
                    // COD Cash in Hand Notice & Settle Action
                    if store.partner.codCashInHand > 0 {
                        codCashInHandCard
                            .padding(.horizontal, 20)
                    }
                    
                    // Linked Bank & Instant IMPS Card
                    linkedBankCard
                        .padding(.horizontal, 20)
                    
                    // Transactions Header & Filter
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("TRANSACTION HISTORY")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(SwiggyColors.mutedText)
                            Spacer()
                            Text("\(filteredTransactions.count) items")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SwiggyColors.mutedText)
                        }
                        
                        // Transaction Filter Pill Bar
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(filterOptions, id: \.self) { opt in
                                    Button(action: {
                                        selectedFilter = opt
                                        HapticManager.playImpact(style: .light)
                                    }) {
                                        Text(opt)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(selectedFilter == opt ? .white : SwiggyColors.mutedText)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(selectedFilter == opt ? SwiggyColors.orange : SwiggyColors.cardLight)
                                            .cornerRadius(16)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Transactions List
                    VStack(spacing: 10) {
                        if filteredTransactions.isEmpty {
                            Text("No transactions in this category.")
                                .font(.system(size: 13))
                                .foregroundColor(SwiggyColors.mutedText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                        } else {
                            ForEach(filteredTransactions) { tx in
                                transactionRow(tx)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showCashoutSheet) {
            cashoutModalView
        }
        .sheet(isPresented: $showCommissionInfoSheet) {
            swiggyCommissionPolicySheet
        }
        .alert("Settle COD Cash", isPresented: $showSettleCodAlert) {
            Button("Settle Full ₹\(Int(store.partner.codCashInHand))") {
                store.settleCodCash()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Reconcile ₹\(Int(store.partner.codCashInHand)) collected from COD deliveries back to Swiggy via UPI QR.")
        }
    }
    
    // MARK: - Digital Wallet Card
    private var digitalWalletCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(SwiggyColors.orange)
                            .font(.system(size: 14))
                        Text("SWIGGY PARTNER PAY")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(SwiggyColors.orange)
                            .tracking(1.0)
                    }
                    Text("Available Wallet Balance")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(SwiggyColors.mutedText)
                }
                
                Spacer()
                
                Image(systemName: "wave.3.right.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(SwiggyColors.orange.opacity(0.8))
            }
            
            // Amount Display
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("₹\(Int(store.partner.walletBalance))")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundColor(.white)
                Text(".00")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(SwiggyColors.mutedText)
                Spacer()
            }
            
            Divider().background(Color.white.opacity(0.12))
            
            // Card Footer & Actions
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("RIDER ID")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(SwiggyColors.mutedText)
                    Text(store.partner.partnerId)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(action: {
                    showCashoutSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.to.line.circle.fill")
                            .font(.system(size: 14))
                        Text("INSTANT CASHOUT")
                            .font(.system(size: 12, weight: .heavy))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(SwiggyColors.emeraldGreen)
                    .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(red: 45/255, green: 56/255, blue: 74/255), Color(red: 28/255, green: 34/255, blue: 48/255)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(SwiggyColors.orange.opacity(0.25), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 10, y: 5)
    }
    
    // MARK: - Wallet Stats Row
    private var walletStatsRow: some View {
        HStack(spacing: 10) {
            statBox(
                title: "Today's Payout",
                amount: "+₹\(Int(store.partner.todayEarnings))",
                icon: "arrow.down.left",
                color: SwiggyColors.emeraldGreen
            )
            
            statBox(
                title: "Swiggy Comm.",
                amount: "-₹\(Int(store.partner.todaySwiggyCommission))",
                icon: "scissors",
                color: SwiggyColors.alertRed
            )
            
            statBox(
                title: "Cash in Hand",
                amount: "₹\(Int(store.partner.codCashInHand))",
                icon: "banknote.fill",
                color: SwiggyColors.warningAmber
            )
        }
    }
    
    private func statBox(title: String, amount: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(color)
                Spacer()
            }
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(SwiggyColors.mutedText)
            Text(amount)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(color)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(SwiggyColors.cardLight)
        .cornerRadius(14)
    }
    
    // MARK: - Swiggy Commission Banner
    private var swiggyCommissionBanner: some View {
        Button(action: {
            showCommissionInfoSheet = true
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(SwiggyColors.orange.opacity(0.15))
                        .frame(width: 42, height: 42)
                    Image(systemName: "percent")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(SwiggyColors.orange)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Swiggy Platform Commission Taken")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("12%")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(SwiggyColors.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(SwiggyColors.orange.opacity(0.15))
                            .cornerRadius(4)
                    }
                    Text("Today's fee: ₹\(Int(store.partner.todaySwiggyCommission)) • Customer tips are 100% commission-free")
                        .font(.system(size: 11))
                        .foregroundColor(SwiggyColors.mutedText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(SwiggyColors.mutedText)
            }
            .padding(14)
            .background(SwiggyColors.cardLight)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(SwiggyColors.orange.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - COD Cash in Hand Card
    private var codCashInHandCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(SwiggyColors.warningAmber.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "banknote.fill")
                    .font(.system(size: 16))
                    .foregroundColor(SwiggyColors.warningAmber)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("COD Cash in Hand: ₹\(Int(store.partner.codCashInHand))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Text("Cash collected from customers to deposit")
                    .font(.system(size: 11))
                    .foregroundColor(SwiggyColors.mutedText)
            }
            
            Spacer()
            
            Button(action: {
                showSettleCodAlert = true
            }) {
                Text("SETTLE")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(SwiggyColors.warningAmber)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(SwiggyColors.warningAmber.opacity(0.15))
                    .cornerRadius(8)
            }
        }
        .padding(14)
        .background(SwiggyColors.cardLight)
        .cornerRadius(14)
    }
    
    // MARK: - Linked Bank Card
    private var linkedBankCard: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "building.columns.fill")
                    .foregroundColor(SwiggyColors.emeraldGreen)
                    .font(.system(size: 15))
                Text("LINKED SETTLEMENT ACCOUNT")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(SwiggyColors.mutedText)
                Spacer()
                Text("IMPS ACTIVE")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(SwiggyColors.emeraldGreen)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(SwiggyColors.emeraldGreen.opacity(0.15))
                    .cornerRadius(4)
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.partner.bankAccountMasked)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Text("UPI ID: \(store.partner.upiId)")
                        .font(.system(size: 11))
                        .foregroundColor(SwiggyColors.mutedText)
                }
                Spacer()
                Text("Verified")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(SwiggyColors.emeraldGreen)
            }
        }
        .padding(16)
        .background(SwiggyColors.cardLight)
        .cornerRadius(14)
    }
    
    // MARK: - Filtered Transactions
    private var filteredTransactions: [WalletTransaction] {
        switch selectedFilter {
        case "Credits (+)":
            return store.walletTransactions.filter { $0.isCredit }
        case "Commission (-)":
            return store.walletTransactions.filter { $0.type == .swiggyCommission }
        case "Cashouts (-)":
            return store.walletTransactions.filter { $0.type == .bankWithdrawal || $0.type == .codSettlement }
        default:
            return store.walletTransactions
        }
    }
    
    // MARK: - Transaction Row
    private func transactionRow(_ tx: WalletTransaction) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(txIconColor(tx).opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: txIconName(tx))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(txIconColor(tx))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tx.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                
                if let note = tx.note {
                    Text(note)
                        .font(.system(size: 11))
                        .foregroundColor(SwiggyColors.mutedText)
                        .lineLimit(1)
                }
                
                Text(formattedDateTime(tx.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(SwiggyColors.mutedText.opacity(0.8))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(tx.isCredit ? "+" : "-")₹\(Int(tx.amount))")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(tx.isCredit ? SwiggyColors.emeraldGreen : (tx.type == .swiggyCommission ? SwiggyColors.orange : SwiggyColors.alertRed))
                
                Text(tx.type.rawValue)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(SwiggyColors.mutedText)
            }
        }
        .padding(14)
        .background(SwiggyColors.cardLight)
        .cornerRadius(14)
    }
    
    private func txIconName(_ tx: WalletTransaction) -> String {
        switch tx.type {
        case .tripPayout: return "bag.fill"
        case .swiggyCommission: return "percent"
        case .incentiveBonus: return "trophy.fill"
        case .bankWithdrawal: return "arrow.down.to.line.compact"
        case .codSettlement: return "arrow.up.circle.fill"
        }
    }
    
    private func txIconColor(_ tx: WalletTransaction) -> Color {
        switch tx.type {
        case .tripPayout: return SwiggyColors.emeraldGreen
        case .swiggyCommission: return SwiggyColors.orange
        case .incentiveBonus: return .purple
        case .bankWithdrawal: return SwiggyColors.alertRed
        case .codSettlement: return SwiggyColors.warningAmber
        }
    }
    
    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, h:mm a"
        return formatter.string(from: date)
    }
    
    // MARK: - Cashout Modal
    private var cashoutModalView: some View {
        ZStack {
            SwiggyColors.deepNavy
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Text("Instant Cashout to Bank")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button("Close") {
                        showCashoutSheet = false
                    }
                    .foregroundColor(SwiggyColors.orange)
                }
                .padding(.top, 24)
                
                VStack(spacing: 8) {
                    Text("Available Wallet Balance")
                        .font(.system(size: 12))
                        .foregroundColor(SwiggyColors.mutedText)
                    Text("₹\(Int(store.partner.walletBalance))")
                        .font(.system(size: 38, weight: .heavy))
                        .foregroundColor(SwiggyColors.emeraldGreen)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(SwiggyColors.cardLight)
                .cornerRadius(16)
                
                // Quick preset buttons
                HStack(spacing: 10) {
                    ForEach([500.0, 1000.0, store.partner.walletBalance], id: \.self) { amt in
                        Button(action: {
                            store.withdrawEarnings(amount: amt)
                            showCashoutSheet = false
                        }) {
                            Text(amt == store.partner.walletBalance ? "Full Balance" : "₹\(Int(amt))")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(SwiggyColors.cardLight)
                                .cornerRadius(12)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transfer Destination:")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(SwiggyColors.mutedText)
                    HStack {
                        Image(systemName: "building.columns.fill")
                            .foregroundColor(SwiggyColors.emeraldGreen)
                        Text(store.partner.bankAccountMasked)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("IMPS 60s")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(SwiggyColors.emeraldGreen)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(10)
                }
                
                Spacer()
                
                Button(action: {
                    store.withdrawEarnings(amount: store.partner.walletBalance)
                    showCashoutSheet = false
                }) {
                    Text("CONFIRM WITHDRAWAL OF ₹\(Int(store.partner.walletBalance))")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(SwiggyColors.emeraldGreen)
                        .cornerRadius(16)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Commission Policy Sheet
    private var swiggyCommissionPolicySheet: some View {
        ZStack {
            SwiggyColors.deepNavy
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TRANSPARENT PRICING")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(SwiggyColors.orange)
                            Text("Commission Taken by Swiggy")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button("Close") {
                            showCommissionInfoSheet = false
                        }
                        .foregroundColor(SwiggyColors.orange)
                    }
                    .padding(.top, 20)
                    
                    Text("Swiggy charges a transparent platform fee on order delivery fares to maintain technology, live routing, insurance, and 24/7 partner support.")
                        .font(.system(size: 13))
                        .foregroundColor(SwiggyColors.mutedText)
                    
                    VStack(spacing: 12) {
                        commissionDetailRow(
                            title: "Delivery Base & Surge Fee",
                            cut: "12% Taken by Swiggy",
                            detail: "Covers trip insurance, server infrastructure, and app maintenance.",
                            icon: "bag.fill",
                            color: SwiggyColors.orange
                        )
                        
                        commissionDetailRow(
                            title: "Customer Tips",
                            cut: "0% Commission (100% Rider)",
                            detail: "100% of customer tips are credited directly into your wallet without any deduction.",
                            icon: "heart.fill",
                            color: .pink
                        )
                        
                        commissionDetailRow(
                            title: "Incentive Bonuses",
                            cut: "0% Commission",
                            detail: "Target bonuses earned during rush hours are credited in full.",
                            icon: "trophy.fill",
                            color: .purple
                        )
                        
                        commissionDetailRow(
                            title: "Rider Accidental Cover",
                            cut: "₹5,00,000 Free Coverage",
                            detail: "Comprehensive accidental and medical insurance provided on all active trips.",
                            icon: "cross.case.fill",
                            color: SwiggyColors.emeraldGreen
                        )
                    }
                }
                .padding(20)
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func commissionDetailRow(title: String, cut: String, detail: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text(cut)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(color)
            }
            Text(detail)
                .font(.system(size: 12))
                .foregroundColor(SwiggyColors.mutedText)
        }
        .padding(14)
        .background(SwiggyColors.cardLight)
        .cornerRadius(12)
    }
}
