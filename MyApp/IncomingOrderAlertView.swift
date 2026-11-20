import SwiftUI

struct IncomingOrderAlertView: View {
    let order: DeliveryOrder
    let remainingSeconds: Int
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Countdown & Alert
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(SwiggyColors.orange)
                        .frame(width: 10, height: 10)
                    Text("NEW ORDER BROADCAST")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(SwiggyColors.orange)
                        .tracking(1.2)
                }
                
                Spacer()
                
                // Countdown ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 3)
                        .frame(width: 36, height: 36)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(remainingSeconds) / 45.0)
                        .stroke(
                            remainingSeconds > 10 ? SwiggyColors.orange : SwiggyColors.alertRed,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 36, height: 36)
                    
                    Text("\(remainingSeconds)s")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            ScrollView {
                VStack(spacing: 16) {
                    // Payout Highlight Card
                    VStack(spacing: 10) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Net Partner Payout")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(SwiggyColors.mutedText)
                                Text("₹\(Int(order.estimatedEarnings))")
                                    .font(.system(size: 34, weight: .heavy))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                if order.surgePay > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "bolt.fill")
                                            .font(.system(size: 10))
                                        Text("+₹\(Int(order.surgePay)) Peak Surge")
                                            .font(.system(size: 11, weight: .bold))
                                    }
                                    .foregroundColor(SwiggyColors.warningAmber)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(SwiggyColors.warningAmber.opacity(0.15))
                                    .cornerRadius(6)
                                }
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 10))
                                    Text("~ \(order.estimatedMinutes) mins")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        // Swiggy Commission & Tip Transparency Bar
                        HStack {
                            Text("Gross: ₹\(Int(order.grossEarnings))")
                                .font(.system(size: 11))
                                .foregroundColor(SwiggyColors.mutedText)
                            Text("•")
                                .foregroundColor(SwiggyColors.mutedText)
                            Text("Swiggy Fee: -₹\(Int(order.swiggyCommission))")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SwiggyColors.alertRed)
                            Spacer()
                            if order.tip > 0 {
                                Text("+₹\(Int(order.tip)) Tip (100% You)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(SwiggyColors.emeraldGreen)
                            }
                        }
                    }
                    .padding(16)
                    .background(SwiggyColors.cardLight)
                    .cornerRadius(14)
                    
                    // Route Timeline (Pickup & Drop)
                    VStack(spacing: 0) {
                        // Pickup Node
                        HStack(alignment: .top, spacing: 14) {
                            VStack(spacing: 4) {
                                Image(systemName: "fork.knife.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(SwiggyColors.orange)
                                Rectangle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 2, height: 36)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text("PICKUP")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(SwiggyColors.orange)
                                    Spacer()
                                    Text("1.2 km away")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(SwiggyColors.mutedText)
                                }
                                Text(order.restaurantName)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                Text(order.restaurantAddress)
                                    .font(.system(size: 12))
                                    .foregroundColor(SwiggyColors.mutedText)
                                    .lineLimit(1)
                            }
                        }
                        
                        // Drop Node
                        HStack(alignment: .top, spacing: 14) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(SwiggyColors.emeraldGreen)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text("DELIVERY DROP")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(SwiggyColors.emeraldGreen)
                                    Spacer()
                                    Text("\(String(format: "%.1f", order.distanceKm)) km total")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(SwiggyColors.mutedText)
                                }
                                Text(order.customerName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Text(order.customerAddress)
                                    .font(.system(size: 12))
                                    .foregroundColor(SwiggyColors.mutedText)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .padding(16)
                    .background(SwiggyColors.cardLight)
                    .cornerRadius(14)
                    
                    // Order Items Preview
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("ORDER SUMMARY (\(order.items.count) ITEMS)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SwiggyColors.mutedText)
                            Spacer()
                            Text(order.orderNumber)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        ForEach(order.items) { item in
                            HStack {
                                Circle()
                                    .fill(item.isVeg ? SwiggyColors.emeraldGreen : SwiggyColors.alertRed)
                                    .frame(width: 8, height: 8)
                                Text("\(item.quantity)x \(item.name)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                        
                        if order.paymentMode == .cashOnDelivery {
                            HStack {
                                Image(systemName: "indianrupeesign.circle.fill")
                                    .foregroundColor(SwiggyColors.warningAmber)
                                Text("Cash On Delivery: Collect ₹\(Int(order.codAmount)) from customer")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(SwiggyColors.warningAmber)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(16)
                    .background(SwiggyColors.cardLight)
                    .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            
            // Bottom Action Controls
            VStack(spacing: 12) {
                Button(action: onAccept) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("ACCEPT ORDER")
                            .font(.system(size: 16, weight: .heavy))
                            .tracking(0.5)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(SwiggyColors.orange)
                    .cornerRadius(16)
                    .shadow(color: SwiggyColors.orange.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                
                Button(action: onReject) {
                    Text("Decline Request")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(SwiggyColors.mutedText)
                        .padding(.vertical, 6)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 10)
            .background(SwiggyColors.deepNavy)
        }
        .background(SwiggyColors.deepNavy)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(SwiggyColors.orange.opacity(0.4), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.6), radius: 20, y: -5)
    }
}
