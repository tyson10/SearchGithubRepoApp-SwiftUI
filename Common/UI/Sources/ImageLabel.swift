import SwiftUI

public struct ImageLabel: View {
    @Binding private var imageUrl: String?
    @Binding private var text: String
    
    public init(imageUrl: Binding<String?> = .constant(nil), text: Binding<String> = .constant("")) {
        self._imageUrl = imageUrl
        self._text = text
    }
    
    public var body: some View {
        HStack {
            URLImage(url: self.imageUrl)
            
            Text(self.text)
        }
    }
}

struct RepositoryRow_Previews: PreviewProvider {
    static var previews: some View {
        ImageLabel()
    }
}
