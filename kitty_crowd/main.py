from . import app
from flask import jsonify


@app.route('/')
def home():
    return jsonify({'message:': 'Meow! Meow meow mrrrp /kitties/<number> meow mrrp meow meow.'})

@app.route('/kitties/<int:n>')
def kitties(n):
    if n < 1:
        return jsonify({'error': 'Hiss!!! Meow meow hisss mreow > 1 meow!!!'}), 400
    if n > 1000:
        return jsonify({'error': 'Hisss!!! Meow meow mrrp meow meow < 1000 meow mrrp!!!'}), 400
    
    kitties = '🐱' * n
    return jsonify({'kitties': kitties})