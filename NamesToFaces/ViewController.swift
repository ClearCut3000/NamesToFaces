//
//  ViewController.swift
//  NamesToFaces
//
//  Created by Николай Никитин on 22.12.2021.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  //MARK: Properties
  var people = [Person]()

  //MARK: - ViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
  }

  //MARK: UIMethods
  @objc func addNewPerson() {
    let picker = UIImagePickerController()
    picker.allowsEditing = true
    picker.delegate = self
    present(picker, animated: true)
  }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[.editedImage] as? UIImage else { return }
    let imageName = UUID().uuidString
    let imagePath = getDocumetsDirectory().appendingPathComponent(imageName)
    if let jpegData = image.jpegData(compressionQuality: 0.8){
      try? jpegData.write(to: imagePath)
    }

    let person = Person(name: "Unknown", image: imageName)
    people.append(person)
    collectionView.reloadData()

    dismiss(animated: true)
  }

  func getDocumetsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }

  //MARK: CollectionView methods
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return people.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else { fatalError("Unable to dequeue PersonCell!") }

    let person = people[indexPath.item]
    cell.name.text = person.name

    let path = getDocumetsDirectory().appendingPathComponent(person.image)
    cell.imageView.image = UIImage(contentsOfFile: path.path)
    cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
    cell.imageView.layer.borderWidth = 2
    cell.imageView.layer.cornerRadius = 3
    cell.layer.cornerRadius = 7

    return cell
  }

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let person = people[indexPath.item]

    let alert = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
    alert.addTextField()
    alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self, weak alert] _ in
      guard let newName = alert?.textFields?[0].text else { return }
      person.name = newName
      self?.collectionView.reloadData()
    })
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(alert, animated: true)
  }
}

