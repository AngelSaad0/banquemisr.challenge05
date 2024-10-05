//
//  MovieTableViewCell.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/3/24.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    // MARK: IBOutlet
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var voteAverageLabel: UILabel!
    @IBOutlet var layerView: UIView!
    // MARK: Properties
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [posterImageView, layerView].forEach {$0.layer.cornerRadius = 16}
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    func config(with cell: Movie, category: MovieAPIProvider ,imageData:Data? = nil) {
        titleLabel.text = cell.title
        releaseDateLabel.text = cell.releaseDate
        if cell.voteAverage != 0.0 {
            voteAverageLabel.text = "★ " + String(format: "%0.1f", cell.voteAverage)
        } else {
            voteAverageLabel.text = "No Rating Yet"
        }
        if let imageData = imageData {
            self.posterImageView.image = UIImage(data: imageData)
        } else {
            let baseImgUrl = "https://image.tmdb.org/t/p/w342"
            guard let posterPath = URL(string: baseImgUrl + cell.posterPath)else {
                print("Error in image cell URL")
                posterImageView.image = UIImage(named: "noPosterImage")
                return
            }
            posterImageView.image = UIImage(named: "loading")
            DispatchQueue.global(qos: .background).async {
                let imageData = try? Data(contentsOf: posterPath)
                DispatchQueue.main.async {
                    let imageData = imageData ?? Data()
                    self.posterImageView.image = UIImage(data: imageData)
                    MovieCoreDataManager.shared.storeMovieImage(imageData, forMovieWithId: cell.id, imageType: .poster)
                }
            }
            
            
        }
    }
}

