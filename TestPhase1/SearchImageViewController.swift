//
//  SearchImageViewController.swift
//  TestPhase1
//
//  Created by Mac Mini on 12/10/21.
//

import UIKit
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFill) {
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
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension SearchImageViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tablecell", for: indexPath) as! Tablecell
        if searching == true{
            cell.tblmgView?.contentMode = .scaleAspectFill
            let complete = searchArray[indexPath.row].largeImageURL
            cell.tblmgView?.download(from: complete)
            let teststring = searchArray[indexPath.row].tags
            let stringreplace = teststring.replacingOccurrences(of: ",", with: " ")
            cell.lbltag.text = stringreplace
            cell.TbleView1.layer.cornerRadius = 30
        }
        else{
        if ischange == true{
            cell.tblmgView?.contentMode = .scaleAspectFill
            let complete = apidata[indexPath.row].largeImageURL
            cell.tblmgView?.downloaded(from: complete)
            let testString = apidata[indexPath.row].tags
            let StringReplace = testString.replacingOccurrences(of: ",",with: " ")
            cell.lbltag.text = StringReplace
            cell.TbleView1.layer.cornerRadius = 30
        }else{
            
       cell.isHidden = true
        
        }
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching == true{
            return searchArray.count
        }
        else{
        if ischange == true {
        return apidata.count
        }
        }
        return apidata.count
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let submit = self.storyboard?.instantiateViewController(identifier: "pushImageController")as! pushImageController
        
     //   submit.delegate = self
        if searching == true{
            submit.image = searchArray[indexPath.row].largeImageURL
            submit.tags = searchArray[indexPath.row].tags
        }else{
        submit.image = apidata[indexPath.row].largeImageURL
        submit.tags = apidata[indexPath.row].tags
        }
        navigationController?.pushViewController(submit, animated: true)
    }
}
class SearchImageViewController: UIViewController, UITextFieldDelegate{
    var fielddata = String()
    
    var apidata = [Apidata]()
    var searchArray = [Apidata]()
    
    @IBOutlet var BtnBarsearch: UIBarButtonItem!
    @IBOutlet var Searchbar: UISearchBar!
    @IBOutlet var TableView: UITableView!
    var searching = false
    var ischange = false
    var isflag = false

//    var delegate: AlertViewControllerdelegate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
      
        Searchbar.placeholder = "Looking for something"
        setupSearchBar()
    }
    
    func setupSearchBar(){
        Searchbar.delegate = self
    }
    
    
    @IBAction func barbuttonSearch(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Search Text", message: "Enter a text", preferredStyle: .alert)
        alert.addTextField { (textField) in
        textField.delegate = self
        }
        
        alert.addAction(UIAlertAction(title: "show", style: .default, handler: { [self, weak alert] (_) in
            

            self.ischange = true
           // var apidata = [Apidata]()
            apidata.removeAll()
            
            let textField = alert?.textFields![0]
            var textfill = (textField?.text)!
            let stringreplace = textfill.replacingOccurrences(of: " ", with: "+")
            
            fielddata = stringreplace
            
            if textField?.text?.count != 0 {
            let url  = URL(string: "https://pixabay.com/api/?key=6535859-9848eef233ce93e8bfb33e5a6&q=\(fielddata)")
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
    //                               print(newData)
                                    
                                    for i in newData {
                                        self.apidata.append(Apidata(dict: i))
                                    }
                                    DispatchQueue.main.async {
                                        self.TableView.reloadData()
                                    }
                                }
                           }
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            }.resume()
             }
        
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension SearchImageViewController: pushImagedelegate{
    func myfunc(_ text1: String, _ text2: String) {
        apidata.append(Apidata.init(dict: [text1 : text2]))
    }
}


extension SearchImageViewController :  UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchArray = []
        searching = true
    
        var trimmed = searchText.trimmingCharacters(in: .whitespaces)
        searchArray = apidata.filter { ($0.tags).range(of: trimmed, options: [ .caseInsensitive ]) != nil }
        
        if searchText.count == 0 {
                searching = false;
                TableView.reloadData()
                searchBar.resignFirstResponder()
            }
        
//           if searchBar.text?.count == 0 {
//
//          SearchImageViewController.load()
//
//               DispatchQueue.main.async {
//                self.Searchbar.resignFirstResponder()
//
//               }
        TableView.reloadData()
        }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.sizeToFit()
        let donebtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donepress))
        toolbar.setItems([donebtn], animated: true)
        Searchbar.inputAccessoryView = toolbar
        
        return true
    }
    @objc func donepress()
    {
        Searchbar.resignFirstResponder()
    
    }
    }
//        searchArray = apidata.filter({$0.tags.lowercased().prefix(searchText.count) == searchText.lowercased()})
//
//         TableView.reloadData()


  //  }
extension SearchImageViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(SearchImageViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class Tablecell: UITableViewCell {
  
    @IBOutlet var TbleView1:UIView!
    @IBOutlet var tblmgView: UIImageView!
    @IBOutlet var lbltag: UILabel!
    @IBOutlet var btnsave: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func btnsave(_ sender: UIButton) {
//        appconstant.isdow = true{
//            btnsave.setImage(<#T##image: UIImage?##UIImage?#>, for: <#T##UIControl.State#>)
//        }
            guard let image = tblmgView.image else { return }
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

class Apidata: NSObject {
        
        var tags: String
        var largeImageURL: String
    
    init(dict:[String:Any]) {
       tags = "\(dict["tags"] ?? "")"
       largeImageURL = "\(dict["largeImageURL"] ?? "")"
        
    }
    
    
}

