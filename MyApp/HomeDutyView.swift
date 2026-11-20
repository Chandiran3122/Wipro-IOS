import SwiftUI

struct HomeDutyView: View {
    @ObservedObject var store: DeliveryStore
    
    var body: some View {
        ZStack {
            SwiggyColors.deepNavy
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Partner Header & Duty Switch
                topPartnerHeader
                
                // Live Shift Summary Bar
                shiftSummaryBar
                
                // Main Area
                if let active = store.activeOrder {
                    ActiveOrderView(store: store, order: active)
                } else {
                    idleRadarContent
                }
            }
            
            // Incoming Order Overlay (if any order is being broadcast)
            if let incoming = store.incomingOrder, store.activeOrder == nil {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack {
                    Spacer()
                    IncomingOrderAlertView(
                        order: incoming,
                        remainingSeconds: store.incomingOrderRemainingSeconds,
                        onAccept: {
                            store.acceptIncomingOrder()
                        },
                        onReject: {
                            store.rejectIncomingOrder()
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .sheet(isPresented: $store.showCelebrationModal) {
            CelebrationModalView(order: store.lastDeliveredOrder) {
                store.showCelebrationModal = false
            }
        }
        .sheet(isPresented: $store.showSOSSheet) {
            SOSSafetySheet()
        }
    }
    
    // MARK: - Top Header
    private var topPartnerHeader: some View {
        HStack(spacing: 12) {
            // Avatar & Name
            ZStack {
                Circle()
                    .fill(SwiggyColors.orange)
                    .frame(width: 44, height: 44)
                Text("RK")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(store.partner.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(SwiggyColors.warningAmber)
                        Text(String(format: "%.2f", store.partner.rating))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(8)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(store.partner.isOnline ? SwiggyColors.emeraldGreen : SwiggyColors.alertRed)
                        .frame(width: 8, height: 8)
                    Text(store.partner.isOnline ? "ON DUTY (AVAILABLE)" : "DUTY OFF")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(store.partner.isOnline ? SwiggyColors.emeraldGreen : SwiggyColors.mutedText)
                }
            }
            
            Spacer()
            
            // Duty Toggle Switch
            Button(action: {
                store.toggleDuty()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "power")
                        .font(.system(size: 13, weight: .black))
                    Text(store.partner.isOnline ? "GO OFF" : "GO DUTY")
                        .font(.system(size: 12, weight: .black))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(store.partner.isOnline ? SwiggyColors.alertRed.opacity(0.8) : SwiggyColors.emeraldGreen)
                .cornerRadius(20)
                .shadow(color: (store.partner.isOnline ? SwiggyColors.alertRed : SwiggyColors.emeraldGreen).opacity(0.3), radius: 6)
            }
            
            // SOS Trigger Button
            Button(action: {
                store.showSOSSheet = true
            }) {
                Image(systemName: "sos.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(SwiggyColors.alertRed)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(SwiggyColors.cardBackground)
    }
    
    // MARK: - Shift Summary Bar
    private var shiftSummaryBar: some View {
        HStack {
            summaryMetricItem(title: "Today's Pay", value: "₹\(Int(store.partner.todayEarnings))", icon: "indianrupeesign", color: SwiggyColors.orange)
            Divider().background(Color.white.opacity(0.1))
            summaryMetricItem(title: "Trips Done", value: "\(store.partner.totalTripsToday)", icon: "bag.fill", color: SwiggyColors.emeraldGreen)
            Divider().background(Color.white.opacity(0.1))
            summaryMetricItem(title: "Swiggy Fee", value: "-₹\(Int(store.partner.todaySwiggyCommission))", icon: "percent", color: SwiggyColors.alertRed)
            Divider().background(Color.white.opacity(0.1))
            summaryMetricItem(title: "Wallet", value: "₹\(Int(store.partner.walletBalance))", icon: "creditcard.fill", color: SwiggyColors.emeraldGreen)
        }
        .frame(height: 52)
        .padding(.horizontal, 12)
        .background(SwiggyColors.cardLight)
    }
    
    private func summaryMetricItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(SwiggyColors.mutedText)
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color)
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Idle State Radar Content
    private var idleRadarContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Claimable Incentive Banner (if any)
                if let claimable = store.incentiveTargets.first(where: { $0.isCompleted && !$0.isClaimed }) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .foregroundColor(SwiggyColors.emeraldGreen)
                            .font(.system(size: 16))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("🎉 \(claimable.title) Achieved!")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Text("Tap to claim +₹\(Int(claimable.bonusAmount)) into your Wallet")
                                .font(.system(size: 11))
                                .foregroundColor(SwiggyColors.emeraldGreen)
                        }
                        Spacer()
                        Button(action: {
                            store.claimIncentive(targetId: claimable.id)
                        }) {
                            Text("CLAIM")
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(SwiggyColors.emeraldGreen)
                                .cornerRadius(8)
                        }
                    }
                    .padding(14)
                    .background(SwiggyColors.cardLight)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(SwiggyColors.emeraldGreen.opacity(0.4), lineWidth: 1)
                    )
                }
                
                if store.partner.isOnline {
                    // Pulsing Radar Box
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(SwiggyColors.orange.opacity(0.2), lineWidth: 40)
                                .frame(width: 140, height: 140)
                            Circle()
                                .stroke(SwiggyColors.orange.opacity(0.4), lineWidth: 20)
                                .frame(width: 90, height: 90)
                            Circle()
                                .fill(SwiggyColors.orange)
                                .frame(width: 50, height: 50)
                                .shadow(color: SwiggyColors.orange.opacity(0.6), radius: 10)
                            Image(systemName: "location.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 24)
                        
                        VStack(spacing: 4) {
                            Text("Searching for High Demand Orders...")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("High surge zone: Indiranagar & Koramangala (+₹25 surge active)")
                                .font(.system(size: 12))
                                .foregroundColor(SwiggyColors.warningAmber)
                        }
                        
                        // Interactive button to trigger demo order
                        Button(action: {
                            store.simulateIncomingOrder()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "bell.badge.fill")
                                Text("SIMULATE INCOMING ORDER")
                                    .font(.system(size: 13, weight: .heavy))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(SwiggyColors.orange)
                            .cornerRadius(12)
                            .shadow(color: SwiggyColors.orange.opacity(0.4), radius: 8)
                        }
                        .padding(.top, 6)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(SwiggyColors.cardLight)
                    .cornerRadius(20)
                } else {
                    // Offline Card
                    VStack(spacing: 14) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 40))
                            .foregroundColor(SwiggyColors.mutedText)
                        Text("You are Offline")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("Turn on duty to start earning and receiving delivery assignments.")
                            .font(.system(size: 13))
                            .foregroundColor(SwiggyColors.mutedText)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            store.toggleDuty()
                        }) {
                            Text("GO ON DUTY NOW")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(SwiggyColors.emeraldGreen)
                                .cornerRadius(12)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(SwiggyColors.cardLight)
                    .cornerRadius(20)
                }
                
                // Hotspot Zone Heatmap & Tips
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(SwiggyColors.orange)
                        Text("HIGH DEMAND CLUSTERS NEAR YOU")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    
                    clusterRow(name: "Indiranagar 100ft Road", ordersRate: "Very High (15+ orders/hr)", surge: "+₹30")
                    clusterRow(name: "Koramangala 5th Block", ordersRate: "High (10+ orders/hr)", surge: "+₹20")
                    clusterRow(name: "Church Street / MG Road", ordersRate: "Moderate (8 orders/hr)", surge: "+₹15")
                }
                .padding(16)
                .background(SwiggyColors.cardLight)
                .cornerRadius(16)
            }
            .padding(16)
        }
    }
    
    private func clusterRow(name: String, ordersRate: String, surge: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(ordersRate)
                    .font(.system(size: 11))
                    .foregroundColor(SwiggyColors.mutedText)
            }
            Spacer()
            Text(surge)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(SwiggyColors.warningAmber)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(SwiggyColors.warningAmber.opacity(0.15))
                .cornerRadius(6)
        }
        .padding(.vertical, 4)
    }
}
