from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    tv_show = "The Office"
    return render_template("index.html", show=tv_show)

if __name__ == "__name__":
    app.run()