//
//  customMarkerView.swift
//  iCycle
//
//  Created by Mario Rendon on 2018-12-02.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import SDWebImage

class CustomMarkerView2: UIView {
    
    var img: String!
    var borderColor: UIColor!
    
    init(frame: CGRect, image: String, borderColor: UIColor) {
        super.init(frame: frame)
        self.img=image
        self.borderColor=borderColor
        setupViews()
    }
    
    func setupViews() {
        let imgView = UIImageView(image: UIImage(named: "placeholder"))
        imgView.sd_setImage(with: URL(string: self.img), placeholderImage: UIImage(named: "placeholder.png"))
        imgView.frame=CGRect(x: 0, y: 0, width: 50, height: 50)
        imgView.layer.cornerRadius = 25
        imgView.layer.borderColor=borderColor?.cgColor
        imgView.layer.borderWidth=4
        imgView.clipsToBounds=true
        let lbl=UILabel(frame: CGRect(x: 0, y: 45, width: 50, height: 10))
        lbl.text = "▾"
        lbl.font=UIFont.systemFont(ofSize: 24)
        lbl.textColor = borderColor
        lbl.textAlignment = .center
        
        self.addSubview(imgView)
        self.addSubview(lbl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
