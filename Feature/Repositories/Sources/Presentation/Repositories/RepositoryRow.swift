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
            
            Text("title")
            
            Text("description")
                .lineLimit(2)
            
            HStack(spacing: 30) {
                HStack(spacing: 2) {
                    Image(systemName: "star")
                    
                    Text("659")
                        .frame(maxHeight: 20)
                }
                
                HStack(spacing: 2) {
                    Image(systemName: "point")
                        .tint(Color.blue)
                    
                    Text("659")
                        .frame(maxHeight: 20)
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

