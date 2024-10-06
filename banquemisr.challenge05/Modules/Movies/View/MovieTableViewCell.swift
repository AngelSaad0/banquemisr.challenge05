//
//  MovieTableViewCell.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/3/24.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var voteAverageLabel: UILabel!
    @IBOutlet var layerView: UIView!

    // MARK: - Properties
    let viewModel: MovieCellViewModel!
    
    // MARK: - Initializer
    required init?(coder: NSCoder) {
        viewModel = MovieCellViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCornerRadius()
        setupViewModel()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: true)
    }
    
    private func setupViewModel() {
        viewModel.setLoadingImage = {
            DispatchQueue.main.async { [weak self] in
                self?.posterImageView.image = UIImage(named: "loading")
            }
        }
        viewModel.setNoPosterImage = {
            DispatchQueue.main.async { [weak self] in
                self?.posterImageView.image = UIImage(named: Constants.noPoster)
            }
        }
        viewModel.setLoadedImage = { imageData in
            DispatchQueue.main.async { [weak self] in
                self?.posterImageView.image = UIImage(data: imageData)
            }
        }
    }

    // MARK: - Configuration
    func config(with cell: Movie, category: MovieAPIProvider, imageData: Data? = nil) {
        titleLabel.text = cell.title
        releaseDateLabel.text = cell.releaseDate
        voteAverageLabel.text = viewModel.formattedVoteAverage(cell.voteAverage)

        if let imageData = imageData {
            posterImageView.image = UIImage(data: imageData)
        } else {
            viewModel.loadImage(for: cell)
        }
    }

    // MARK: - Private Methods
    private func setupCornerRadius() {
        [posterImageView, layerView].forEach { $0.layer.cornerRadius = 16 }
    }
}
