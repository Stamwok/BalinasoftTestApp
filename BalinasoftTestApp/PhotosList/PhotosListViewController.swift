//
//  ViewController.swift
//  BalinasoftTestApp
//
//  Created by Егор Шуляк on 22.09.23.
//

import UIKit
import Combine

class PhotosListViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.register(PhotosListTableViewCell.self, forCellReuseIdentifier: PhotosListTableViewCell.reuseId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = footerView
        tableView.allowsMultipleSelection = false
        return tableView
    }()
    private lazy var loadingIndicatior: UIActivityIndicatorView = {
       let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()
    private lazy var footerView: UIView = {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 100))
        let spinner = UIActivityIndicatorView()
        footerView.addSubview(spinner)
        spinner.center = footerView.center
        spinner.startAnimating()
        return footerView
    }()
    
    // MARK: - Private properties
    
    private var bag = Set<AnyCancellable>()
    private var items: [PhotosListTableCellModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Public properties
    
    var viewModel: PhotosListViewModel? {
        didSet {
            guard let viewModel else { return }
            bind(viewModel: viewModel)
        }
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel?.send(event: .onAppear)
    }
    
    // MARK: - Private methods
    
    private func bind(viewModel: PhotosListViewModel) {
        viewModel.$state
            .sink { [weak self] state in
                self?.render(state: state)
            }.store(in: &bag)
    }
    
    private func render(state: PhotosListViewModel.State) {
        switch state.currentState {
        case .idle:
            break
        case .sendingPhoto:
            loadingIndicatior.startAnimating()
            tableView.isUserInteractionEnabled = false
        case .loaded(let items, let isLastPage, let message):
            loadingIndicatior.stopAnimating()
            tableView.isUserInteractionEnabled = true
            self.items = items
            if isLastPage {
                self.tableView.tableFooterView = nil
            }
            if let message {
                showAlert(title: "Success", message: message)
            }
        case .showingCamera:
            showCamera()
        case .error(let error):
            loadingIndicatior.stopAnimating()
            showAlert(title: "Error", message: error)
        default:
            break
        }
    }
    
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Photo types"
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        view.addSubview(loadingIndicatior)
        NSLayoutConstraint.activate([
            loadingIndicatior.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicatior.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
}

// MARK: - Extension for UITableViewDelegate

extension PhotosListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? PhotosListTableViewCell {
            viewModel?.send(event: .onShowCamera(photoTypeId: cell.model?.id ?? -1))
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == tableView.numberOfSections - 1 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 && !(viewModel?.state.isLastPage ?? true) {
              viewModel?.send(event: .onLoadMore)
          }
      }
}

// MARK: - Extension for UITableViewDataSource

extension PhotosListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        items[indexPath.row].cellForTableView(tableView: tableView, atIndexPath: indexPath) 
    }
}

// MARK: - Extension for UIImagePickerControllerDelegate

extension PhotosListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        viewModel?.send(event: .onPhotoTaked(image))
        self.dismiss(animated: true)
    }
}
