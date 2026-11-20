import SwiftUI

struct PerformanceView: View {
    @ObservedObject var store: DeliveryStore
    
    var body: some View {
        ZStack {
            SwiggyColors.deepNavy
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SCORECARD & BADGES")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(SwiggyColors.orange)
                            Text("Rider Performance")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Main Rating Hero Card
                    VStack(spacing: 12) {
                        HStack(spacing: 6) {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(SwiggyColors.warningAmber)
                            }
                        }
                        
                        Text(String(format: "%.2f", store.partner.rating))
                            .font(.system(size: 44, weight: .heavy))
                            .foregroundColor(.white)
                        
                        Text("Top 5% Delivery Partner in Bengaluru East")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(SwiggyColors.emeraldGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(SwiggyColors.emeraldGreen.opacity(0.15))
                            .cornerRadius(12)
                        
                        Text("Based on last 500 customer & restaurant ratings")
                            .font(.system(size: 11))
                            .foregroundColor(SwiggyColors.mutedText)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(SwiggyColors.cardLight)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    
                    // Core KPI Metrics Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("KEY METRICS")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(SwiggyColors.mutedText)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            metricCard(
                                title: "Acceptance Rate",
                                value: "\(Int(store.partner.acceptanceRate))%",
                                subtitle: "Target: >90%",
                                icon: "checkmark.seal.fill",
                                color: SwiggyColors.emeraldGreen
                            )
                            
                            metricCard(
                                title: "On-Time Rate",
                                value: "98.2%",
                                subtitle: "Average delay: 0 mins",
                                icon: "clock.badge.checkmark.fill",
                                color: SwiggyColors.orange
                            )
                            
                            metricCard(
                                title: "Cancellation Rate",
                                value: "0.2%",
                                subtitle: "Platform best (<1%)",
                                icon: "shield.lefthalf.filled",
                                color: .cyan
                            )
                            
                            metricCard(
                                title: "Hygiene & Bag",
                                value: "100%",
                                subtitle: "Inspected yesterday",
                                icon: "sparkles",
                                color: .purple
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Achievement Badges
                    VStack(alignment: .leading, spacing: 12) {
                        Text("EARNED BADGES")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(SwiggyColors.mutedText)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                badgeItem(title: "Super Fast", subtitle: "200+ on-time", icon: "bolt.fill", color: SwiggyColors.warningAmber)
                                badgeItem(title: "Monsoon Hero", subtitle: "50+ rain trips", icon: "cloud.rain.fill", color: .cyan)
                                badgeItem(title: "Night Owl", subtitle: "100+ late orders", icon: "moon.stars.fill", color: .indigo)
                                badgeItem(title: "5-Star Favorite", subtitle: "150+ 5-star tips", icon: "heart.fill", color: .pink)
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.horizontal, -20)
                    }
                    .padding(.horizontal, 20)
                    
                    // Real Customer Compliments
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CUSTOMER COMPLIMENTS")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(SwiggyColors.mutedText)
                        
                        complimentRow(text: "Delivered steaming hot food 10 minutes before estimated time! Very polite.", author: "Pooja K. • Indiranagar")
                        complimentRow(text: "Handled heavy downpour without spilling a drop of soup. Real champion!", author: "Arun M. • Koramangala")
                        complimentRow(text: "Followed the 'don't ring bell' instruction perfectly. Thank you so much!", author: "Suresh P. • HSR Layout")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
    
    private func metricCard(title: String, value: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(SwiggyColors.mutedText)
        }
        .padding(14)
        .background(SwiggyColors.cardLight)
        .cornerRadius(14)
    }
    
    private func badgeItem(title: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 54, height: 54)
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(SwiggyColors.mutedText)
        }
        .frame(width: 108)
        .padding(.vertical, 14)
        .background(SwiggyColors.cardLight)
        .cornerRadius(14)
    }
    
    private func complimentRow(text: String, author: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\"\(text)\"")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
            Text(author)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(SwiggyColors.orange)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SwiggyColors.cardLight)
        .cornerRadius(12)
    }
}
