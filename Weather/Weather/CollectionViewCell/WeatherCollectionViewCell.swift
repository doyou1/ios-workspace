//
//  WeatherCollectionViewCell.swift
//  Weather
//
//  Created by simjh on 2023/07/19.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var iconImageview: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    
    static let identifier = "WeatherCollectionViewCell"

    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell", bundle: nil)
    }
    
    func config(with model: HourlyWeather) {
        self.tempLabel.text = "\(model.temp)°C"

        let imgSrc = "https:\(model.condition.icon)"
        guard let url = URL(string: imgSrc) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Error handling...
            guard let imageData = data else {
                print("Error : \(String(describing: error))")
                return
            }
            DispatchQueue.main.async {
                self.iconImageview.image = UIImage(data: imageData)
            }
        }.resume()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
