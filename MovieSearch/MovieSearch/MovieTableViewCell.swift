//
//  MovieTableViewCell.swift
//  MovieSearch
//
//  Created by simjh on 2023/07/21.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var posterImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static let identifier = "MovieTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "MovieTableViewCell", bundle: nil)
    }
    
    func configure(with model: Movie) {
        self.titleLabel.text = model.Title
        self.yearLabel.text = model.Year
        guard let url = URL(string: model.Poster) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Error handling...
            guard let imageData = data else {
                print("Error : \(String(describing: error))")
                return
            }
            DispatchQueue.main.async {
                self.posterImage.image = UIImage(data: imageData)
            }
        }.resume()
    }
    
}
