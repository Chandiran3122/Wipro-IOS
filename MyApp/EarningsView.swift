import SwiftUI

struct EarningsView: View {
    @ObservedObject var store: DeliveryStore
    @State private var selectedPeriod: String = "Today"
    @State private var showWithdrawAlert: Bool = false
    @State private var showCommissionSheet: Bool = false
    
    private let periods = ["Today", "This Week", "This Month"]
    
    var body: some View {
        ZStack {
            SwiggyColors.deepNavy
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Title Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("PAYOUTS & FINANCIALS")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(SwiggyColors.orange)
                            Text("Partner Earnings")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Period Picker Segmented Control
                    HStack(spacing: 8) {
                        ForEach(periods, id: \.self) { period in
                            Button(action: {
                                selectedPeriod = period
                                HapticManager.playImpact(style: .light)
                            }) {
                                Text(period)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(selectedPeriod == period ? .white : SwiggyColors.mutedText)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(selectedPeriod == period ? SwiggyColors.orange : SwiggyColors.cardLight)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Main Net Payout & Withdrawable Card
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selectedPeriod == "Today" ? "Today's Net Take-Home" : (selectedPeriod == "This Week" ? "This Week's Net" : "This Month's Net"))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(SwiggyColors.mutedText)
                                
                                Text(displayEarningsAmount)
                                    .font(.system(size: 38, weight: .heavy))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("In Wallet")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(SwiggyColors.mutedText)
                                Text("₹\(Int(store.partner.walletBalance))")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(SwiggyColors.emeraldGreen)
                            }
                        }
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        // Summary breakdown row
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Gross Fare")
                                    .font(.system(size: 10))
                                    .foregroundColor(SwiggyColors.mutedText)
                                Text("₹\(Int(currentGrossEarnings))")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .center, spacing: 2) {
                                Text("Swiggy Comm. (Taken)")
                                    .font(.system(size: 10))
                                    .foregroundColor(SwiggyColors.alertRed)
                                Text("-₹\(Int(currentCommission))")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(SwiggyColors.alertRed)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Tips & Incentives")
                                    .font(.system(size: 10))
                                    .foregroundColor(SwiggyColors.emeraldGreen)
                                Text("+₹\(Int(currentTipsAndIncentives))")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(SwiggyColors.emeraldGreen)
                            }
                        }
                    }
                    .padding(20)
                    .background(SwiggyColors.cardLight)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    
                    // Swiggy Commission Transparency Card
                    swiggyCommissionBreakdownCard
                        .padding(.horizontal, 20)
                    
                    // Earnings Breakdown Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DETAILED PAY BREAKDOWN")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(SwiggyColors.mutedText)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            breakdownTile(title: "Base Order Pay", amount: "₹\(Int(store.partner.todayEarnings * 0.60))", icon: "bag.fill", color: SwiggyColors.orange)
                            breakdownTile(title: "Surge & Peak Pay", amount: "₹\(Int(store.partner.todayEarnings * 0.20))", icon: "bolt.fill", color: SwiggyColors.warningAmber)
                            breakdownTile(title: "Customer Tips (100%)", amount: "₹\(Int(store.partner.todayEarnings * 0.15))", icon: "heart.fill", color: .pink)
                            breakdownTile(title: "Commission Taken", amount: "-₹\(Int(store.partner.todaySwiggyCommission))", icon: "scissors", color: SwiggyColors.alertRed)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Active Incentive Targets Summary
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("INCENTIVES & TARGETS")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(SwiggyColors.mutedText)
                            Spacer()
                            Text("See Hub")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SwiggyColors.orange)
                        }
                        
                        ForEach(store.incentiveTargets.prefix(2)) { target in
                            IncentiveProgressCard(target: target)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Recent Trips Ledger
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("RECENT DELIVERIES & COMMISSION DEDUCTIONS")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(SwiggyColors.mutedText)
                            Spacer()
                            Text("\(store.completedTrips.count) Trips")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        ForEach(store.completedTrips) { trip in
                            tripLedgerRow(trip: trip)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
    
    // MARK: - Swiggy Commission Breakdown Card
    private var swiggyCommissionBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "percent")
                        .foregroundColor(SwiggyColors.orange)
                        .font(.system(size: 14, weight: .bold))
                    Text("COMMISSION TAKEN BY SWIGGY")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(SwiggyColors.orange)
                }
                
                Spacer()
                
                Text("-₹\(Int(currentCommission))")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(SwiggyColors.alertRed)
            }
            
            Text("Swiggy applies a 12% platform fee on base & surge pay for server infrastructure, routing AI, and rider accidental insurance.")
                .font(.system(size: 12))
                .foregroundColor(SwiggyColors.mutedText)
            
            Divider().background(Color.white.opacity(0.08))
            
            HStack {
                Label("0% Commission on Tips", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(SwiggyColors.emeraldGreen)
                Spacer()
                Label("0% on Bonuses", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(SwiggyColors.emeraldGreen)
            }
        }
        .padding(16)
        .background(SwiggyColors.cardLight)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(SwiggyColors.orange.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var displayEarningsAmount: String {
        switch selectedPeriod {
        case "Today": return "₹\(Int(store.partner.todayEarnings))"
        case "This Week": return "₹\(Int(store.partner.weeklyEarnings))"
        default: return "₹\(Int(store.partner.weeklyEarnings * 3.8))"
        }
    }
    
    private var currentGrossEarnings: Double {
        switch selectedPeriod {
        case "Today": return store.partner.todayEarnings + store.partner.todaySwiggyCommission
        case "This Week": return store.partner.weeklyEarnings + store.partner.weeklySwiggyCommission
        default: return (store.partner.weeklyEarnings * 3.8) + (store.partner.weeklySwiggyCommission * 3.8)
        }
    }
    
    private var currentCommission: Double {
        switch selectedPeriod {
        case "Today": return store.partner.todaySwiggyCommission
        case "This Week": return store.partner.weeklySwiggyCommission
        default: return store.partner.weeklySwiggyCommission * 3.8
        }
    }
    
    private var currentTipsAndIncentives: Double {
        switch selectedPeriod {
        case "Today": return (store.partner.todayEarnings * 0.15) + 300
        case "This Week": return (store.partner.weeklyEarnings * 0.15) + 800
        default: return (store.partner.weeklyEarnings * 3.8 * 0.15) + 2400
        }
    }
    
    private func breakdownTile(title: String, amount: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Spacer()
            }
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(SwiggyColors.mutedText)
            Text(amount)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(14)
        .background(SwiggyColors.cardLight)
        .cornerRadius(14)
    }
    
    private func tripLedgerRow(trip: CompletedTripRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(trip.orderNumber)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(SwiggyColors.orange)
                    Text("• \(trip.customerArea)")
                        .font(.system(size: 12))
                        .foregroundColor(SwiggyColors.mutedText)
                }
                Text(trip.restaurantName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text("\(String(format: "%.1f", trip.distanceKm)) km • \(formattedTime(trip.timestamp))")
                        .font(.system(size: 11))
                        .foregroundColor(SwiggyColors.mutedText)
                    
                    Text("Swiggy Fee: -₹\(Int(trip.swiggyCommission))")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(SwiggyColors.alertRed)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("₹\(Int(trip.earnings))")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(SwiggyColors.emeraldGreen)
                if trip.tip > 0 {
                    Text("+₹\(Int(trip.tip)) tip")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(SwiggyColors.warningAmber)
                }
            }
        }
        .padding(14)
        .background(SwiggyColors.cardLight)
        .cornerRadius(14)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

struct IncentiveProgressCard: View {
    let target: IncentiveTarget
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(target.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text(target.description)
                        .font(.system(size: 11))
                        .foregroundColor(SwiggyColors.mutedText)
                }
                Spacer()
                Text("₹\(Int(target.bonusAmount))")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(SwiggyColors.warningAmber)
            }
            
            // Progress Bar
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)
                        Capsule()
                            .fill(target.isCompleted ? SwiggyColors.emeraldGreen : SwiggyColors.orange)
                            .frame(width: geo.size.width * CGFloat(target.progress), height: 8)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(target.completedOrders)/\(target.targetOrders) completed")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(target.isCompleted ? SwiggyColors.emeraldGreen : .white)
                    Spacer()
                    Text("Expires \(target.deadline)")
                        .font(.system(size: 10))
                        .foregroundColor(SwiggyColors.mutedText)
                }
            }
        }
        .padding(16)
        .background(SwiggyColors.cardLight)
        .cornerRadius(14)
    }
}
