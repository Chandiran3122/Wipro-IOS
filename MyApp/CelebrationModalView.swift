import SwiftUI

struct CelebrationModalView: View {
    let order: DeliveryOrder?
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            SwiggyColors.deepNavy
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Celebration Badge
                ZStack {
                    Circle()
                        .fill(SwiggyColors.emeraldGreen.opacity(0.15))
                        .frame(width: 110, height: 110)
                    Circle()
                        .fill(SwiggyColors.emeraldGreen)
                        .frame(width: 80, height: 80)
                        .shadow(color: SwiggyColors.emeraldGreen.opacity(0.5), radius: 12)
                    Image(systemName: "checkmark")
                        .font(.system(size: 38, weight: .black))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 6) {
                    Text("Trip Completed!")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundColor(.white)
                    Text("Great work! Your net payout has been credited directly to your wallet.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(SwiggyColors.mutedText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                if let order = order {
                    // Payout Breakdown Card
                    VStack(spacing: 14) {
                        VStack(spacing: 2) {
                            Text("NET CREDITED TO WALLET")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(SwiggyColors.emeraldGreen)
                            Text("₹\(Int(order.estimatedEarnings))")
                                .font(.system(size: 42, weight: .heavy))
                                .foregroundColor(SwiggyColors.orange)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        VStack(spacing: 8) {
                            earningRow(title: "Base Delivery Pay", amount: order.basePay)
                            if order.surgePay > 0 {
                                earningRow(title: "Peak Hour Surge", amount: order.surgePay, highlight: true)
                            }
                            if order.tip > 0 {
                                earningRow(title: "Customer Tip (100% Kept)", amount: order.tip, highlight: true)
                            }
                            earningRow(title: "Swiggy Commission Taken", amount: order.swiggyCommission, isDeduction: true)
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            earningRow(title: "Trip Distance", value: "\(String(format: "%.1f", order.distanceKm)) km")
                            earningRow(title: "Payment Mode", value: order.paymentMode.rawValue)
                        }
                    }
                    .padding(20)
                    .background(SwiggyColors.cardLight)
                    .cornerRadius(18)
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Action Button
                Button(action: onDismiss) {
                    HStack {
                        Image(systemName: "bicycle")
                        Text("FIND NEXT DELIVERY")
                            .font(.system(size: 15, weight: .heavy))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(SwiggyColors.orange)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    private func earningRow(title: String, amount: Double? = nil, value: String? = nil, highlight: Bool = false, isDeduction: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(SwiggyColors.mutedText)
            Spacer()
            if let amount = amount {
                Text("\(isDeduction ? "- " : "")₹\(Int(amount))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(isDeduction ? SwiggyColors.alertRed : (highlight ? SwiggyColors.emeraldGreen : .white))
            } else if let value = value {
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}
