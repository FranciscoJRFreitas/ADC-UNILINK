from flask import Flask, request, jsonify
import yake

app = Flask(__name__)

def extractKeywords(text):
    language = "pt"
    max_ngram_size = 1
    deduplication_thresold = 0.9
    deduplication_algo = 'seqm'
    windowSize = 1
    numOfKeywords = 20

    kw_extractor = yake.KeywordExtractor(lan=language, 
                                         n=max_ngram_size, 
                                         dedupLim=deduplication_thresold, 
                                         dedupFunc=deduplication_algo, 
                                         windowsSize=windowSize, 
                                         top=numOfKeywords)
                                            
    results = kw_extractor.extract_keywords(text)

    keywords = []

    for res in results:
        keywords.append(res[0]) 

    return keywords

@app.route('/extract', methods=['POST'])
def extract_keywords_route():
    if not request.json or 'text' not in request.json:
        return jsonify({'error': 'No text provided'}), 400

    text = request.json['text']
    keywords = extractKeywords(text)

    return jsonify({'keywords': keywords})
