//
//  PhotosListTableCellModel.swift
//  BalinasoftTestApp
//
//  Created by Егор Шуляк on 23.09.23.
//

import Foundation
import UIKit

final class PhotosListTableCellModel {
    
    let id: Int
    let imageUrl: URL?
    let title: String
    
    init(photoDTO: PhotoDTO) {
        id = photoDTO.id ?? -1
        imageUrl = URL(string: photoDTO.image ?? "")
        title = photoDTO.name ?? ""
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotosListTableViewCell.reuseId, for: indexPath)
        if let cell = cell as? PhotosListTableViewCell {
            cell.configure(with: self)
        }
        return cell
    }
}

extension PhotosListTableCellModel: Equatable {
    static func == (lhs: PhotosListTableCellModel, rhs: PhotosListTableCellModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.imageUrl == rhs.imageUrl &&
        lhs.title == rhs.title
    }
}
