const int gridSizeX = 17;
const int gridSizeY = 17;

const int matrixSize = gridSizeX * gridSizeY;

const int greyScaleMapSize = 70;
const char greyScaleMap[greyScaleMapSize+1] = "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~<>i!lI;:,\"^`'. ";

int analogPins[gridSizeX] = {22,21,20,19,18,17,16,15,14,A22,A21,39,38,37,36,35,34};
int digitalPins[gridSizeY] = {3,4,5,6,7,8,9,10,11,12,30,24,25,26,27,28,29};
int valueArray[gridSizeX*gridSizeY];


void setup(){
  Serial.begin(115200);
  for (size_t i = 0; i < gridSizeX; i++) {
    pinMode(analogPins[i], INPUT);
  }

  for (size_t i = 0; i < gridSizeY; i++) {
    pinMode(digitalPins[i], INPUT);
  }
}


void loop(){
  for (size_t y = 0; y < gridSizeY; y++) {
    pinMode(digitalPins[y], OUTPUT);
    digitalWrite(digitalPins[y], HIGH);
    delay(1);

    for (size_t x = 0; x < gridSizeX; x++) {
      int arrayIndex = y * gridSizeX + x;
      // resetValueArray();
      // delay(250);
      int value = analogRead(analogPins[x]);
      valueArray[arrayIndex] = value;
      pinMode(analogPins[x], INPUT);
      int constrainedValue = map(value, 0, 1024, 70, 0);
      // Serial.printf("%c", greyScaleMap[constrainedValue]);
      // Serial.printf("%i\t", constrainedValue);
      Serial.printf("%i;", value);
      // Serial.print("  ");
      // printValues();
    }
    // Serial.println();

    pinMode(digitalPins[y], INPUT);
  }
  Serial.println();
  // delay(50);
}

void resetValueArray(){
  for (size_t i = 0; i < matrixSize; i++) {
    valueArray[i] = 512;
  }
}

void printValues(){
  for (size_t i = 0; i < matrixSize; i++) {
    Serial.printf("%i;", valueArray[i]);
  }
  // Serial.println();
}
