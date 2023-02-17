//
//  RepositoryRow.swift
//  Repositories
//
//  Created by Taeyoung Son on 2023/02/04.
//

import SwiftUI

import CommonUI

struct RepositoryRow: View {
    var body: some View {
        VStack(alignment: .leading) {
            ImageLabel(text: .constant("username"))
            
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

struct RepositoryRow_Previews: PreviewProvider {
    static var previews: some View {
        RepositoryRow()
    }
}

