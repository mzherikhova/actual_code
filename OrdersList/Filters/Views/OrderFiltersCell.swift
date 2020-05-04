//
//  OrderFiltersCell.swift
//  ros
//
//  Created by Margarita Zherikhova on 30/09/2019.
//  Copyright © 2019 rosprom. All rights reserved.
//

import Foundation

protocol OrderFiltersCelllDelegate : class {
    func settingChanged(orderStatus:OrderStatus)
}

class OrderFiltersCell : UITableViewCell {
    weak var delegate : OrderFiltersCelllDelegate?
    
    var switcher : UISwitch!
    var line : UIView!
    var orderStatus : OrderStatus? {
        didSet {
            onSettingSet()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.reapplyStyle(TextStyle.cellLabel)
        switcher = UISwitch(frame: .zero)
        switcher.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        switcher.onTintColor = UIColor.accent
        switcher.isOn = false
        self.accessoryView = switcher
        self.selectionStyle = .none
        line = UIView()
        line.backgroundColor = UIColor.rosDisabled
        self.addSubview(line)
    }
    
    func adjustSeparatorLine(fullWidth: Bool) {
        line.snp.remakeConstraints { (snp) in
            if fullWidth {
                snp.right.left.bottom.equalToSuperview()
            } else {
                snp.right.bottom.equalToSuperview()
                snp.left.equalToSuperview().offset(15)
            }
            snp.height.equalTo(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onSettingSet() {
        guard let setting = self.orderStatus else {
            return
        }
        self.textLabel?.text = setting.name
        switcher.isOn = setting.status
    }
    
    @objc
    func switchChanged() {
        guard let _ = orderStatus else {
            return
        }
        let value = switcher.isOn
        self.orderStatus!.status = value
        delegate?.settingChanged(orderStatus: self.orderStatus!)
    }
}
