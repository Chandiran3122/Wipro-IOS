import SwiftUI

struct SwipeActionButton: View {
    let title: String
    let subtitle: String?
    let iconName: String
    let sliderColor: Color
    let action: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isCompleted: Bool = false
    
    private let thumbWidth: CGFloat = 58
    
    init(
        title: String,
        subtitle: String? = nil,
        iconName: String = "chevron.right.2",
        sliderColor: Color = SwiggyColors.orange,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.sliderColor = sliderColor
        self.action = action
    }
    
    var body: some View {
        GeometryReader { geometry in
            let maxDrag = max(0, geometry.size.width - thumbWidth - 10)
            
            ZStack(alignment: .leading) {
                // Background Track
                RoundedRectangle(cornerRadius: 30)
                    .fill(SwiggyColors.cardLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                
                // Active Fill
                RoundedRectangle(cornerRadius: 30)
                    .fill(sliderColor.opacity(0.25))
                    .frame(width: max(thumbWidth + 10, dragOffset + thumbWidth + 5))
                
                // Track Text
                HStack {
                    Spacer()
                    VStack(spacing: 2) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .textCase(.uppercase)
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(SwiggyColors.mutedText)
                        }
                    }
                    .padding(.leading, 40)
                    Spacer()
                }
                
                // Sliding Thumb Handle
                ZStack {
                    Circle()
                        .fill(sliderColor)
                        .shadow(color: sliderColor.opacity(0.5), radius: 6, x: 2, y: 2)
                    
                    Image(systemName: isCompleted ? "checkmark" : iconName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: thumbWidth, height: thumbWidth)
                .padding(.leading, 5)
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard !isCompleted else { return }
                            let translation = value.translation.width
                            if translation > 0 {
                                dragOffset = min(translation, maxDrag)
                                if dragOffset > maxDrag * 0.4 {
                                    HapticManager.playImpact(style: .light)
                                }
                            }
                        }
                        .onEnded { value in
                            guard !isCompleted else { return }
                            if dragOffset >= maxDrag * 0.75 {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    dragOffset = maxDrag
                                    isCompleted = true
                                }
                                HapticManager.playNotification(type: .success)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    action()
                                    withAnimation {
                                        dragOffset = 0
                                        isCompleted = false
                                    }
                                }
                            } else {
                                withAnimation(.interactiveSpring()) {
                                    dragOffset = 0
                                }
                                HapticManager.playImpact(style: .rigid)
                            }
                        }
                )
            }
        }
        .frame(height: 64)
    }
}
