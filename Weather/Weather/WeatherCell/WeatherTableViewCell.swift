//
//  WeatherUITableViewCell.swift
//  Weather
//
//  Created by simjh on 2023/07/17.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var highTempLabel: UILabel!
    @IBOutlet var lowTempLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    static let identifier = "WeatherTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
    }
    
    func configure(with model: ForecastWeather) {

        self.lowTempLabel.text = "\(model.minTemp)°C"
        self.highTempLabel.text = "\(model.maxTemp)°C"
        self.dayLabel.text = model.date
        
        let imgSrc = "https:\(model.condition.icon)"
        guard let url = URL(string: imgSrc) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Error handling...
            guard let imageData = data else {
                print("Error : \(String(describing: error))")
                return
            }
            DispatchQueue.main.async {
                self.iconImageView.image = UIImage(data: imageData)
            }
        }.resume()
    }
}
