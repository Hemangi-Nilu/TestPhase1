//
//  pushImageController.swift
//  TestPhase1
//
//  Created by Nilu Technologies 1 on 22/10/21.
//

import UIKit
extension UIImageView {
    func downloadede(from url: URL, contentMode mode: ContentMode = .scaleAspectFill) {
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
    func downloadede(from link: String, contentMode mode: ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        download(from: url, contentMode: mode)
    }
}
class pushImageController: UIViewController {
    var image:String = ""
    var tags:String = ""
    var delegate:pushImagedelegate!

    @IBOutlet var imgPush: UIImageView!
    @IBOutlet var lblPush: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let complete = image
        imgPush?.download(from: complete)
        let testString = tags
        var StringReplace = testString.replacingOccurrences(of: ",",with: " ")
        lblPush.text = StringReplace
    }
    
    @IBAction func btnDownload(_ sender: Any) {
        guard let image = imgPush.image else { return }
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
protocol  pushImagedelegate{
    func myfunc(_ text1:String,_ text2:String)
    }
