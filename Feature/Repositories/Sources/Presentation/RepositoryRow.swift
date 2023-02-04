//
//  RepositoryRow.swift
//  Repositories
//
//  Created by Taeyoung Son on 2023/02/04.
//

import SwiftUI

struct RepositoryRow: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Color(.black)
                    .frame(width: 20, height: 20)
                
                Color(.black)
                    .frame(maxHeight: 20)
            }
            
            Text("tmap")
            
            Text("R package for maps")
            
            HStack {
                Color(.black)
                    .frame(width: 20, height: 20)
                
                Text("659")
                    .frame(maxHeight: 20)
                
                Color(.black)
                    .frame(width: 20, height: 20)
                
                Text("R")
                    .frame(maxHeight: 20)
            }
        }
    }
}

struct RepositoryRow_Previews: PreviewProvider {
    static var previews: some View {
        RepositoryRow()
    }
}

