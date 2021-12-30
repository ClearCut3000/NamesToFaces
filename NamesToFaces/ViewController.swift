//
//  ViewController.swift
//  NamesToFaces
//
//  Created by Николай Никитин on 22.12.2021.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  //MARK: - Properties
  var people = [Person]()

  //MARK: - ViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))

    let defaults = UserDefaults.standard
    
    if let savedPeople = defaults.object(forKey: "people") as? Data {
      if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] {
        people = decodedPeople
      }
    }
  }

  //MARK: - UIMethods
  @objc func addNewPerson() {
    let alert = UIAlertController(title: "Please, choose image source!", message: nil, preferredStyle: .actionSheet)
    let picker = UIImagePickerController()
    picker.allowsEditing = true
    picker.delegate = self
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      alert.addAction(UIAlertAction(title: "Camera", style: .default){ action in
        picker.sourceType = .camera
        self.present(picker, animated: true)
      })
    }
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      alert.addAction(UIAlertAction(title: "PhotoLibrary", style: .default){ action in
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true)
      })
    }
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alert, animated: true)
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
    save()
    collectionView.reloadData()

    dismiss(animated: true)
  }

  func getDocumetsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }

  func save(){
    if let saveData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) {
      let defaults = UserDefaults.standard
      defaults.set(saveData, forKey: "people")

    }
  }

  //MARK: - CollectionView methods
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return people.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
      fatalError("Unable to dequeue PersonCell!")
    }

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
      self?.save()
      self?.collectionView.reloadData()
    })
    alert.addAction(UIAlertAction(title: "Delete", style: .default){ [weak self] _ in
      if ((self?.people.contains(person)) != nil){
        guard let index = self?.people.firstIndex(of: person) else { return }
        self?.people.remove(at: index)
      }
      self?.collectionView.reloadData()
    })
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(alert, animated: true)
  }
}

