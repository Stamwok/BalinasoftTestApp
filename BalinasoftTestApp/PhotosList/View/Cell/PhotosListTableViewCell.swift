//
//  PhotosListTableViewCell.swift
//  BalinasoftTestApp
//
//  Created by Егор Шуляк on 23.09.23.
//

import Foundation
import UIKit
import Kingfisher

final class PhotosListTableViewCell: UITableViewCell {
    
    static let reuseId = String(describing: PhotosListTableViewCell.self)
    
    // MARK: - Views
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    var model: PhotosListTableCellModel?
    
    func configure(with model: PhotosListTableCellModel) {
        self.model = model
        photoImageView.kf.setImage(with: model.imageUrl)
        titleLabel.text = model.title
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        contentView.addSubview(photoImageView)
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 50),
            photoImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
}
