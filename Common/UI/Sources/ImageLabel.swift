import SwiftUI

public struct ImageLabel: View {
    @Binding private var imageUrl: String?
    @Binding private var text: String
    @Binding private var imageSize: CGSize
    @State private var font: Font = .system(size: 15)
    
    public init(
        imageUrl: Binding<String?> = .constant(nil),
        text: Binding<String> = .constant(""),
        imageSize: Binding<CGSize> = .constant(.zero)
    ) {
        self._imageUrl = imageUrl
        self._text = text
        self._imageSize = imageSize
    }
    
    public var body: some View {
        HStack {
            URLImage(url: self.imageUrl)
                .frame(
                    width: self.imageSize.width,
                    height: self.imageSize.height,
                    alignment: .center
                )
            
            Text(self.text)
                .font(self.font)
        }
    }
    
    public func font(_ font: Font) -> Self {
        self.font = font
        return self
    }
}

struct RepositoryRow_Previews: PreviewProvider {
    static var previews: some View {
        ImageLabel()
    }
}
