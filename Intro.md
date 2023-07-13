## Getting started after deploying DeepSparse Inference Runtime

After the [DeepSparse One-Click Droplet](<https://github.com/neuralmagic/deepsparse/blob/b028422aff667487e973eb99418907b765d283f4/examples/do-marketplace/README.md>) is created, access your Droplet via SSH by using your Droplet's IP address:<br>

`ssh root@<IP-ADDRESS> -L 5543:localhost:5543`

This command is used to establish a secure SSH tunnel and forward a port from a remote machine to your local machine for model serving. As soon as you log in, you are now ready to deploy and run state of the art computer vision and natural language processing models!

## Machine Learning Inference on CPUs

[DeepSparse](https://neuralmagic.com/deepsparse/) enables developers of all experience levels to execute Deep Learning models for a diverse range of Natural Language Processing and Computer Vision tasks on CPUs.

Let's start using the [DeepSparse Server](https://github.com/neuralmagic/deepsparse/blob/860044680e4361ae28aa8687d9d93ced59e5053d/docs/user-guide/deepsparse-server.md) to make predictions. This server has been optimized to handle machine learning inference. You ask it to make a prediction by sending an API request, and it sends the prediction back to you.

### YOLOv8 for Computer Vision Object Detection

<img src="https://neuralmagic.com/wp-content/uploads/2023/03/coomputer_vision.svg" alt="computer_vision" width="600"/>

Object detection is a crucial task in the field of Computer Vision that empowers computers to perceive and identify specific objects within images. It enables machines to "see" and accurately recognize various elements depicted in photographs. Let's say you have a photo that contains a cat, a dog, and a tree. Object detection involves utilizing a deep learning model to analyze that photo and accurately identify the objects present within it, as well as determine their respective locations.

For this task, we'll use a [sparse YOLOv8](https://sparsezoo.neuralmagic.com/models/yolov8-s-coco-pruned50_quantized), which is a state-of-the-art model for the object detection task.

**Step 1)** From your Droplet's terminal, initialize the DeepSparse Server with the YOLOv8 model:

```bash
deepsparse.server --task yolov8 --model_path zoo:cv/detection/yolov8-s/pytorch/ultralytics/coco/pruned50_quant-none
```

**Step 2)** From your local machine's terminal, download the example image `human-dog.jpg` into your working directory:

```bash
wget -O human-dog.jpg https://raw.githubusercontent.com/neuralmagic/deepsparse/main/docs/use-cases/cv/images/human-dog.jpg
```

**Step 3)** On your local machine, use the Python `requests` and `opencv` libraries (`pip install requests opencv`) to make an API request to receive YOLOv8's inference on what it "sees" in the picture and then draw boxes with labels in our image to know which objects it identified:

```python
import requests
import cv2

def draw_boxes_on_image(image_path: str, output_path: str, url: str):
    # Send the image to the server and get the response
    with open(image_path, "rb") as image_file:
        detections = requests.post(url, files={"request": (image_path, image_file)}).json()

    # Load and draw the bounding boxes on the image
    image = cv2.imread(image_path)
    for box, score, label in zip(detections['boxes'][0], detections['scores'][0], detections['labels'][0]):
        x1, y1, x2, y2 = box
        cv2.rectangle(image, (int(x1), int(y1)), (int(x2), int(y2)), (0, 255, 0), 2)
        cv2.putText(image, f'{label}: {score:.2f}', (int(x1), int(y1) - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (36, 255, 12), 2)

    # Save the image
    cv2.imwrite(output_path, image)
```

**Step 4)** Call the `draw_boxes_on_image` function and pass in the the source image path, newly annotated output path and the server's url:

```python
draw_boxes_on_image("human-dog.jpg", "human-dog-boxes.jpg", "http://0.0.0.0:5543/predict/from_files")
```

Here are all the objects identified by the model found in the new `human-dog-boxes.jpg` image:

<img src="https://raw.githubusercontent.com/neuralmagic/deepsparse/main/docs/use-cases/cv/images/human-dog-boxes.jpg" alt="human-dog-boxes" width="600"/>

Now you can try your own images! YOLOv8 can detect [over 80 different classes](https://gist.github.com/AruniRC/7b3dadd004da04c80198557db5da4bda) - people, animals, plants, cars, and many more. 

**[Optional] Step 5)** For more advanced setup, create the below yaml file as `config.yaml` and initialize the server with it. This will select the YOLOv8 model and the dataset labels the model expects to classify objects in images:

```yaml
endpoints:
  - task: yolov8
    model: zoo:cv/detection/yolov8-s/pytorch/ultralytics/coco/pruned50_quant-none
    kwargs:
      class_names: "coco"
```
```bash
deepsparse.server --config-file config.yaml
``` 

### BERT for NLP Sentiment Analysis

<img src="https://neuralmagic.com/wp-content/uploads/2023/03/NLP_image-1.png" alt="nlp" width="600"/>

Sentiment analysis is a common task in Natural Language Processing that focuses on identifying and classifying opinions expressed in a piece of text. Imagine you're a business that receives thousands of social media comments and posts about your product every day. Sentiment analysis could involve using a machine learning model to process these social media interactions and determine the general sentiment towards your product — be it positive or negative.

For this task, we'll use a sparse BERT model, which is a transformer model for the sentiment analysis task. The model was trained to classify text into 2 sentiments: `positive` and `negative`. In addition, it also gives a score on how confident the model is in its prediction.

**Step 1)** From your Droplet's terminal, initialize the DeepSparse Server with the BERT model:

```bash
deepsparse.server --task sentiment_analysis --model_path zoo:nlp/sentiment_analysis/obert-base/pytorch/huggingface/sst2/pruned90_quant-none
```

**Step 2)** On your local machine's terminal, use `curl` to make an API request to receive BERT's inference on the sentiment of a tweet:

```bash
 curl -X POST -H "Content-Type: application/json" -d '{"sequences": "Hey @neuralmagic, DeepSparse is an an awesome piece of software!"}' http://localhost:5543/predict
```

Here is the output, where DeepSparse correctly labeled the message as positive: 
```
{"labels":["positive"],"scores":[0.9994332790374756]}
```

Now you can try your own text! This BERT was fine-tuned on [customer reviews](https://huggingface.co/datasets/sst2) so it is adept at classification on full sentences.

## Resources

Thank you for deploying the Neural Magic DeepSparse droplet. Visit our [SparseZoo](sparsezoo.neuralmagic.com) full of other state-of-the-art fine-tuned ML models that you can run on DeepSparse - just copy a model stub and run. 

You also can find many explanations, examples, and tutorials in our video library at https://neuralmagic.com/video/. For an in-depth view over all of the advanced DeepSparse features such as benchmarking inference scenarios, different pipeline tasks, and the model server, [please visit the API guide](<https://github.com/neuralmagic/deepsparse/blob/fd223aa935cef42c9c6dfcea62b14e003e0d6de5/docs/user-guide/README.md>).

Please note that this distribution features the community license and is not for commercial use.  View [our community license details](https://neuralmagic.com/legal/deepsparse-license-agreement/), or go to https://neuralmagic.com/deepsparse/#form for a commercial license.
