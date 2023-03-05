//
//  RepositoryRow.swift
//  Repositories
//
//  Created by Taeyoung Son on 2023/02/04.
//

import SwiftUI

import CommonUI
import Model

struct RepositoryRow: View {
    @State var repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ImageLabel(
                imageUrl: .constant(repository.owner.avatarURL),
                text: .constant(repository.name),
                imageSize: .constant(.init(width: 20, height: 20))
            )
            .font(.system(size: 11))
            
            Text(self.repository.name)
            
            Spacer()
                .frame(height: 3)
            
            Text(self.repository.description ?? "")
                .lineLimit(2)
                .font(.system(size: 17))
            
            HStack(spacing: 30) {
                HStack(spacing: 2) {
                    Image(systemName: "star")
                    
                    Text("\(self.repository.stargazersCount)")
                        .frame(maxHeight: 20)
                        .font(.system(size: 12))
                }
                
                HStack(spacing: 2) {
                    Image(systemName: "point")
                        .tint(Color.blue)
                    
                    Text(self.repository.language ?? "")
                        .frame(maxHeight: 20)
                        .font(.system(size: 12))
                }
            }
        }
    }
}

//struct RepositoryRow_Previews: PreviewProvider {
//    static var previews: some View {
////        RepositoryRow(repository: <#Repository#>)
//    }
//}

