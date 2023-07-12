import requests
import cv2

def draw_boxes_on_image(image_path, url):
    # Send the image to the server and get the response
    with open(image_path, "rb") as image_file:
        response = requests.post(url, files={"request": (image_path, image_file)})

    # Load the image with cv2
    image = cv2.imread(image_path)

    # Parse the response
    detections = response.json()

    # Draw the bounding boxes on the image
    for box, score, label in zip(detections['boxes'][0], detections['scores'][0], detections['labels'][0]):
        x1, y1, x2, y2 = box
        cv2.rectangle(image, (int(x1), int(y1)), (int(x2), int(y2)), (0, 255, 0), 2)
        cv2.putText(image, f'{label}: {score:.2f}', (int(x1), int(y1) - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (36,255,12), 2)

    # Save the image
    cv2.imwrite('basilica_boxes.jpg', image)

# Use the function
draw_boxes_on_image("basilica.jpg", "http://0.0.0.0:5543/predict/from_files")