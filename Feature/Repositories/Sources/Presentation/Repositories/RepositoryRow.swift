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
    
    private let langColorSize: CGFloat = 7
    
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
            
            Text(repository.name)
            
            Spacer()
                .frame(height: 3)
            
            Text(repository.description ?? "")
                .lineLimit(2)
                .font(.system(size: 17))
            
            HStack(spacing: 30) {
                HStack(spacing: 2) {
                    Image(systemName: "star")
                    
                    Text("\(repository.stargazersCount)")
                        .frame(maxHeight: 20)
                        .font(.system(size: 12))
                }
                
                HStack(spacing: 2) {
                    repository.langColor?.color?
                        .frame(width: langColorSize, height: langColorSize)
                        .cornerRadius(langColorSize/2)
                    
                    Text(repository.language ?? "")
                        .frame(maxHeight: 20)
                        .font(.system(size: 12))
                }
            }
        }
    }
}
