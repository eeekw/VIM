//
//  MessagesCell.swift
//  VIM
//
//  Created by Leaf on 2018/1/14.
//  Copyright © 2018年 leaf. All rights reserved.
//

import UIKit
import SnapKit

class MessagesCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var iconView : UIView?
    var messageView : UIView?
    var messageLabel : UILabel?
    
    var message: Message? {
        didSet {
            messageLabel?.text = message?.text
            self.setNeedsUpdateConstraints()
//            self.updateConstraintsIfNeeded()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        iconView = UIView()
        iconView?.backgroundColor = UIColor.red
        contentView.addSubview(iconView!)
        
        messageView = UIView()
        messageView?.backgroundColor = UIColor.green
        messageView?.layer.cornerRadius = 3
        contentView.addSubview(messageView!)
        
        messageLabel = UILabel()
        messageLabel?.font = UIFont.systemFont(ofSize: 12)
        messageLabel?.textColor = UIColor.blue
        messageLabel?.numberOfLines = 0
        messageView?.addSubview(messageLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        if message?.from == 0 {
            
            iconView?.snp.remakeConstraints({ (make) in
                make.top.equalTo(15)
                make.right.equalTo(-15)
                make.width.height.equalTo(35)
            })
            
            messageView?.snp.remakeConstraints({ (make) in
                
                make.top.equalTo(iconView!)
                make.right.equalTo(iconView!.snp.left).offset(-15)
                make.left.greaterThanOrEqualTo(15)
                make.bottom.equalTo(-15)
            })
            
        } else {
            
            iconView?.snp.remakeConstraints({ (make) in
                make.top.equalTo(15)
                make.left.equalTo(15)
                make.width.height.equalTo(35)
            })
            
            messageView?.snp.remakeConstraints({ (make) in
                
                make.top.equalTo(iconView!)
                make.left.equalTo(iconView!.snp.right).offset(15)
                make.right.lessThanOrEqualTo(-15)
                make.bottom.equalTo(-15)
            })
        }
        
        messageLabel?.snp.remakeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsetsMake(8, 10, 8, 10))
        })
        
        super.updateConstraints()
    }
}
