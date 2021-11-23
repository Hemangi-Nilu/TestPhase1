//
//  RandomImageViewController.swift
//  TestPhase1
//
//  Created by Mac Mini on 12/10/21.
//

import UIKit
import Photos
extension UIImageView {
    func download(from url: URL, contentMode mode: ContentMode = .scaleAspectFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func download(from link: String, contentMode mode: ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        download(from: url, contentMode: mode)
    }
}

class RandomImageViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
   
    var index = IndexPath()
    @IBOutlet var CollectView: UICollectionView!
    var Apidata = [AApidata]()
    override func viewDidLoad() {
        super.viewDidLoad()

        let url  = URL(string: "https://pixabay.com/api/?key=6535859-9848eef233ce93e8bfb33e5a6&q")
        guard let serviceUrl = url else { return }
        
        var request = URLRequest(url: serviceUrl)
        
        request.httpMethod = "GET"
    
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 20
        
        URLSession.shared.dataTask(with: serviceUrl) { (data, responce, error) in
            if error == nil{
                do{
                    if let data = data {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let newData = json["hits"] as? [[String:Any]]{
//                                print(newData)
                                
                                for i in newData {
                                    self.Apidata.append(AApidata(dict: i))
                                }
                        }
                    }
                    }
                }catch{
                    print(error.localizedDescription)
                }
                
                DispatchQueue.main.async {
                    self.CollectView.reloadData()
                }
            }
        }.resume()
        
        
    }
    
    }

extension RandomImageViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Apidata.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectcell", for: indexPath)as! collectcell
        
       
        cell.ImgCollect?.contentMode = .scaleAspectFill
        let complete = Apidata[indexPath.row].largeImageURL
        cell.ImgCollect?.download(from: complete)
        cell.layer.cornerRadius = 20
        
        let testString = Apidata[indexPath.row].tags
        let StringReplace = testString.replacingOccurrences(of: ",",with: " ")
        cell.lbltags.text = StringReplace
      
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let submit = self.storyboard?.instantiateViewController(identifier: "RandomPushController")as! RandomPushController
        submit.delegate = self
        submit.image = Apidata[indexPath.row].largeImageURL
        submit.tags = Apidata[indexPath.row].tags
     //   submit.index = indexPath.row
        navigationController?.pushViewController(submit, animated: true)
    }
    
}
extension RandomImageViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CollectView.bounds.width - 40

        return CGSize(width:width/2, height: width/2)
    }
}
extension RandomImageViewController: RandomPushControllerdelegate{
    func myfunc(_ text1: String, _ text2: String) {
        Apidata.append(AApidata.init(dict: [text1 : text2]));
        CollectView.reloadData()
    }
   
}
class collectcell: UICollectionViewCell {
    
    @IBOutlet weak var ImgCollect: UIImageView!
    @IBOutlet var btnSave: UIButton!
    @IBOutlet var lbltags: UILabel!
    override func awakeFromNib() {
        
        super.awakeFromNib()
       
}
    @IBAction func btnsave(_ sender: UIButton) {
        guard let image = ImgCollect.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error  {
            // we got back an error!
            print("failed")
        } else {
           print("success")
        }
    }
}
class AApidata: NSObject {
        
        var tags: String
        var largeImageURL: String
    
    init(dict:[String:Any]) {
       tags = "\(dict["tags"] ?? "")"
       largeImageURL = "\(dict["largeImageURL"] ?? "")"

    }
    
    
}


