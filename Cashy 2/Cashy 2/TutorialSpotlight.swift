import SwiftUI

private struct TutorialTargetPreferenceKey: PreferenceKey {
    static var defaultValue: [TutorialHighlightTarget: Anchor<CGRect>] = [:]

    static func reduce(
        value: inout [TutorialHighlightTarget: Anchor<CGRect>],
        nextValue: () -> [TutorialHighlightTarget: Anchor<CGRect>]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

extension View {
    func tutorialTarget(_ target: TutorialHighlightTarget) -> some View {
        anchorPreference(key: TutorialTargetPreferenceKey.self, value: .bounds) {
            [target: $0]
        }
    }

    func tutorialSpotlightHost() -> some View {
        modifier(TutorialSpotlightHostModifier())
    }
}

private struct TutorialSpotlightHostModifier: ViewModifier {
    @EnvironmentObject private var appData: AppData
    @EnvironmentObject private var tutorial: AppTutorialController

    func body(content: Content) -> some View {
        content.overlayPreferenceValue(TutorialTargetPreferenceKey.self) { anchors in
            GeometryReader { proxy in
                if tutorial.isActive,
                   let anchor = anchors[tutorial.currentStep.target] {
                    let targetRect = proxy[anchor]

                    TutorialSpotlightOverlay(
                        rect: targetRect,
                        step: tutorial.currentStep,
                        progressText: tutorial.progressText,
                        onNext: {
                            tutorial.advance(appData: appData)
                        },
                        onSkip: {
                            tutorial.skip(appData: appData)
                        }
                    )
                    .transition(.opacity)
                }
            }
            .ignoresSafeArea()
        }
    }
}

private struct TutorialSpotlightOverlay: View {
    let rect: CGRect
    let step: AppTutorialStep
    let progressText: String
    let onNext: () -> Void
    let onSkip: () -> Void

    private var spotlightRect: CGRect {
        rect.insetBy(dx: -step.spotlightPadding, dy: -step.spotlightPadding)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()

                Path { path in
                    path.addRect(CGRect(origin: .zero, size: proxy.size))
                    path.addRoundedRect(
                        in: spotlightRect,
                        cornerSize: CGSize(width: step.cornerRadius, height: step.cornerRadius)
                    )
                }
                .fill(Color.black.opacity(0.74), style: FillStyle(eoFill: true))
                .contentShape(Rectangle())

                RoundedRectangle(cornerRadius: step.cornerRadius)
                    .stroke(Color.white.opacity(0.95), lineWidth: 2)
                    .frame(width: spotlightRect.width, height: spotlightRect.height)
                    .position(x: spotlightRect.midX, y: spotlightRect.midY)
                    .shadow(color: .white.opacity(0.18), radius: 18)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Tutorial \(progressText)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.9))

                        Spacer()

                        Button("Überspringen", action: onSkip)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.9))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(step.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Text(step.message)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }

                    Button(action: onNext) {
                        Text(step.primaryActionTitle)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.black.opacity(0.86))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .ignoresSafeArea()
    }
}
