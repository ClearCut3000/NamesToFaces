//
//  Person.swift
//  NamesToFaces
//
//  Created by Николай Никитин on 26.12.2021.
//

import UIKit

class Person: NSObject, NSCoding {
  var name: String
  var image: String

  init(name: String, image: String) {
    self.name = name
    self.image = image
  }

  required init?(coder aDecoder: NSCoder) {
    name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
    image = aDecoder.decodeObject(forKey: "image") as? String ?? ""
  }

  func encode(with aCoder: NSCoder) {
    aCoder.encode(name, forKey: "name")
    aCoder.encode(image, forKey: "image")
  }
}
