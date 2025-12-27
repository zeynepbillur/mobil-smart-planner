class Response {
  constructor(data = null, message = null) {
    this.data = data;
    this.message = message;
  }

  //200 (OK)
  success(res) {
    return res.status(200).json({
      status: true,
      message: this.message ?? "İşlem başarılı",
      data: this.data,
    });
  }

  //201 (Created)
  created(res) {
    return res.status(201).json({
      status: true,
      message: this.message ?? "İşlem başarılı",
      data: this.data,
    });
  }

  //500 Internal Server Error
  error500(res) {
    return res.status(500).json({
      status: false,
      message: this.message ?? "İşlem başarısız !",
      data: this.data,
    });
  }

  //400 (Bad Request)
  error400(res) {
    return res.status(400).json({
      status: false,
      message: this.message ?? "İşlem başarısız !",
      data: this.data,
    });
  }

  //401 (Unauthorized)
  error401(res) {
    return res.status(401).json({
      status: false,
      message: this.message ?? "Geçersiz oturum, lütfen oturum açın!",
      data: this.data,
    });
  }

  //404 (Not Found)
  error404(res) {
    return res.status(404).json({
      status: false,
      message: this.message ?? "İşlem başarısız !",
      data: this.data,
    });
  }

  //429 Too Many Requests
  error429(res) {
    return res.status(429).json({
      status: false,
      message: this.message ?? "Çok fazla istek atıldı !",
      data: this.data,
    });
  }
    error423(res) {
    return res.status(423).json({
      status: false,
      message: this.message ?? "Kaynak kilitli",
      data: this.data,
    });
  }
}


module.exports = Response;
