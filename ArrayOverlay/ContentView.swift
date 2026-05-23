import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var image: NSImage? = nil

    @State private var offset: CGSize = .zero
    @State private var baseOffset: CGSize = .zero

    @State private var scale: CGFloat = 1.0
    @State private var baseScale: CGFloat = 1.0

    @State private var rotation: Angle = .zero
    @State private var baseRotation: Angle = .zero

    @State private var opacity: Double = 0.7
    @State private var clickThrough: Bool = false

    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()

            if let image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(opacity)
                    .scaleEffect(scale)
                    .rotationEffect(rotation)
                    .offset(offset)
                    .gesture(adjustGesture)
                    .padding(8)
            } else {
                Text("Click “Add Roof” to add roof imagery.")
                    .padding()
                    .background(Color.black.opacity(0.35))
                    .cornerRadius(12)
            }

            VStack {
                HStack(spacing: 10) {
                    Button("Add Roof") { openImage() }
                    Button("Reset") { resetTransform() }

                    Divider().frame(height: 18)

                    Text("Opacity")
                    Slider(value: $opacity, in: 0.15...0.95)
                        .frame(width: 140)

                    Spacer()

                    Text(clickThrough ? "CLICK-THROUGH" : "ADJUST")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            clickThrough ? Color.red.opacity(0.85)
                                         : Color.blue.opacity(0.85)
                        )
                        .cornerRadius(8)
                }
                .padding(10)
                .background(Color.black.opacity(0.35))
                .cornerRadius(14)
                .padding()

                Spacer()
            }
        }
        .onAppear { setWindowClickThrough(clickThrough) }
        .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
            handleDrop(providers: providers)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ToggleClickThrough"))) { _ in
            clickThrough.toggle()
        }
    }

    private var adjustGesture: some Gesture {
        let drag = DragGesture()
            .onChanged { value in
                guard !clickThrough else { return }
                offset = CGSize(
                    width: baseOffset.width + value.translation.width,
                    height: baseOffset.height + value.translation.height
                )
            }
            .onEnded { _ in baseOffset = offset }

        let magnify = MagnificationGesture()
            .onChanged { value in
                guard !clickThrough else { return }
                scale = baseScale * value
            }
            .onEnded { _ in baseScale = scale }

        let rotate = RotationGesture()
            .onChanged { value in
                guard !clickThrough else { return }
                rotation = baseRotation + value
            }
            .onEnded { _ in baseRotation = rotation }

        return drag.simultaneously(with: magnify).simultaneously(with: rotate)
    }

    private func resetTransform() {
        offset = .zero
        baseOffset = .zero
        scale = 1.0
        baseScale = 1.0
        rotation = .zero
        baseRotation = .zero
        opacity = 0.7
    }

    private func openImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            UTType.png,
            UTType.jpeg,
            UTType.tiff,
            UTType.bmp,
            UTType.heic
        ]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            image = NSImage(contentsOf: url)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
            guard
                let data = item as? Data,
                let url = URL(dataRepresentation: data, relativeTo: nil)
            else { return }

            DispatchQueue.main.async {
                self.image = NSImage(contentsOf: url)
            }
        }
        return true
    }

    private func setWindowClickThrough(_ enabled: Bool) {
        DispatchQueue.main.async {
            guard let window = NSApplication.shared.windows.first else { return }
            window.ignoresMouseEvents = enabled
        }
    }
}

