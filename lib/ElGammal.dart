import 'dart:io';
import 'dart:math';
import 'dart:core';

List<Point> pointCollection = [];

List<BigInt> range = [];

int mikroU = generateMikroU();

BigInt nParam = generateN();

Point pM;

BigInt messageToEncode;

// Parsing B hex to dec

BigInt calculateB() {
  return BigInt.parse(
      "5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b",
      radix: 16);
}

// Calculate value of P

BigInt calculateP() {
  return BigInt.from(2).pow(256) -
      BigInt.from(2).pow(224) +
      BigInt.from(2).pow(192) +
      BigInt.from(2).pow(96) -
      BigInt.from(1);
}

// Calculate Delta(E)

BigInt calculatedeltaE() {
  return (BigInt.from(4) * BigInt.from(-3).pow(3) +
          BigInt.from(27) * calculateB().pow(2)) %
      calculateP();
}

// Main method

void main(List<String> arguments) {
  num choice;
  BigInt x, y;

  print("------------------------------------");
  print("Welcome to elliptic curve calculator");
  print("------------------------------------");
  print("E: Y^2 = X^3 - 3X + B");
  print("A = ${BigInt.from(-3)}");
  print("B(decimal) = ${calculateB()}");
  print("P = 2^256 - 2^224 + 2^192 + 2^96 - 1 = ${calculateP()}");
  print("------------------------------");
  print("What do you want to do?");
  print("------------------------------");
  print("Programming task 1:");
  print("1 - Get random points and make calculations on them");
  print("2 - Check if the point belongs to the elliptic curve");
  print("------------------------------");
  print("Programming task 2:");
  print("3 - Encode and decode message");
  print("------------------------------");
  print("Programming task 3:");
  print("4 - El Gamal cryptosystem implementation");
  print("------------------------------");
  print("Choose number and click enter:");

  choice = num.parse(stdin.readLineSync());

  switch (choice) {
    case 1:
      {
        findRandomPoints(2);
        printResults();
      }
      break;
    case 2:
      {
        print("------------------------------------------------");
        print("Check if the point belongs to the elliptic curve");
        print("------------------------------------------------");
        print("Enter X coordinate: ");
        x = BigInt.parse(stdin.readLineSync());

        print("Enter Y coordinate: ");
        y = BigInt.parse(stdin.readLineSync());

        belongsToCollection(x, y);
      }
      break;
    case 3:
      {
        print("-------------------------");
        print("Encode and decode message");
        print("-------------------------");
        print("Enter message as number (for example: 73456378): ");
        messageToEncode = BigInt.parse(stdin.readLineSync());
        print(
            "Result of encoding: Pm = ${encode(messageToEncode, mikroU, nParam)}\n");
        print("Message after decoding: ${decode(pM, mikroU)}");
      }
      break;
    case 4:
      {
        print("-------------------------");
        print("El Gamal cryptosystem");
        print("-------------------------");
        print("Enter message as number (for example: 73456378): \n");
        messageToEncode = BigInt.parse(stdin.readLineSync());
        print("-------------------------");
        print("Alice generates keys:");
        print("-------------------------\n");
        alice();
      }
      break;
    default:
      {
        print("Invalid choice");
      }
  }
}

class Point {
  BigInt xParam;
  BigInt yParam;

  Point(this.xParam, this.yParam);

  @override
  String toString() {
    return '{x: $xParam, y: $yParam}';
  }
}

// Finding random points and printing results to the screen

findRandomPoints(howManyPoints) {
  for (int i = 0; i < howManyPoints; i++) {
    BigInt x1 = randomX(getRandomBigInt());
    while (!isQuadraticResidue(x1)) {
      x1 = randomX(getRandomBigInt());
    }
    BigInt yCalc1 = calcRightSide(x1);
    BigInt y1 = mySqrt(yCalc1);

    Point P = Point(x1, y1);
    pointCollection.add(P);
  }
}

// Square root calculation

BigInt bSqrt(BigInt number) {
  BigInt temp;
  BigInt sr = number ~/ BigInt.two;

  do {
    temp = sr;
    sr = (temp + (number ~/ temp)) ~/ BigInt.two;
  } while ((temp - sr) != BigInt.zero);

  return sr;
}

// Calculate P + P

Point sum2P(Point P) {
  BigInt x1 = P.xParam;
  BigInt y1 = P.yParam;

  BigInt lambda1 = (x1.pow(2) * BigInt.from(3)) % calculateP();
  BigInt lambda2 = (lambda1 + BigInt.from(-3)) % calculateP();
  BigInt lambda3 = (y1 * BigInt.from(2)).modInverse(calculateP());
  BigInt lambda = lambda2 * lambda3;

  BigInt x3First = lambda.pow(2);
  BigInt x3Second = x1 * (BigInt.from(2));
  BigInt x3 = (x3First - x3Second) % calculateP();

  BigInt y3First = x1 - x3;
  BigInt y3Second = y3First * lambda;
  BigInt y3 = (y3Second - y1) % calculateP();

  return Point(x3, y3);
}

// Calculate P + Q

Point sumPQ(Point P, Point Q) {
  BigInt x1 = P.xParam;
  BigInt y1 = P.yParam;
  BigInt x2 = Q.xParam;
  BigInt y2 = Q.yParam;

  BigInt lambda1 = (y2 - y1) % calculateP();
  BigInt lambda2 = (x2 - x1).modInverse(calculateP());
  BigInt lambda = lambda1 * lambda2;

  BigInt x3First = lambda.pow(2);
  BigInt x3 = (x3First - x1 - x2) % calculateP();

  BigInt y3First = x1 - x3;
  BigInt y3Second = lambda * y3First;
  BigInt y3 = (y3Second - y1) % calculateP();

  return Point(x3, y3);
}

// Calculate P - P

subtractPP() {
  return print("P - P = O\n");
}

// Calculate P + O

sumPO() {
  return print(
      "P + O = P = (${pointCollection[0].xParam}, ${pointCollection[0].yParam})\n");
}

printResults() {
  print("-----------------------------------");
  print("Points Collection (random P and Q):");
  print("-----------------------------------");
  print("P = (${pointCollection[0].xParam}, ${pointCollection[0].yParam})\n");
  print("Q = (${pointCollection[1].xParam}, ${pointCollection[1].yParam})\n");
  sumPQ(Point(pointCollection[0].xParam, pointCollection[0].yParam),
      Point(pointCollection[1].xParam, pointCollection[1].yParam));
  sum2P(Point(pointCollection[0].xParam, pointCollection[0].yParam));
  subtractPP();
  sumPO();
}

// Check if point belongs to curve

belongsToCollection(BigInt x, BigInt y) {
  if (((x.pow(3) - BigInt.from(3) * x + calculateB()) % calculateP()) ==
      ((y.pow(2)) % calculateP())) {
    print("\nPoint belongs to curve");
    return true;
  } else {
    print("\nPoint does not belong to curve");
    return false;
  }
}

// Finding random Big Integer

BigInt randomX(BigInt max) {
  Random random = new Random();
  int digits = max.toString().length;
  BigInt out = BigInt.from(0);
  do {
    var str = "";
    for (int i = 0; i < digits; i++) {
      str += random.nextInt(10).toString();
    }
    out = BigInt.parse(str);
  } while (out < max);
  return out;
}

BigInt fillList() {
  Random random = new Random();
  int digits = calculateP().toString().length;
  BigInt out = BigInt.from(0);
  do {
    var str = "";
    for (int i = 0; i < digits; i++) {
      str += random.nextInt(10).toString();
      out = BigInt.parse(str);
      range.add(out);
    }
  } while (out < calculateP());
}

BigInt mySqrt(BigInt x) {
  BigInt exp = calculateP() + BigInt.one;
  BigInt exp2 = exp ~/ BigInt.from(4);
  BigInt sqrt = x.modPow(exp2, calculateP());
  return sqrt;
}

// Calculating right side of equation

BigInt calcRightSide(x) {
  BigInt result = (x.pow(3) - BigInt.from(3) * x + calculateB()) % calculateP();
  return result;
}

getRandomBigInt() {
  fillList();
  Random rnd = new Random();
  var element = range[rnd.nextInt(range.length)];
  return element;
}

// Check existance of quadratic residue

bool isQuadraticResidue(BigInt x) {
  BigInt exp = (calculateP() - BigInt.one) ~/ BigInt.from(2);
  return calcRightSide(x).modPow(exp, calculateP()) == BigInt.from(1);
}

// Check if point belongs to curve

belongsToCurve(BigInt x, BigInt y) {
  if (((x.pow(3) - BigInt.from(3) * x + calculateB()) % calculateP()) ==
      ((y.pow(2)) % calculateP())) {
    return true;
  } else {
    return false;
  }
}

// Return Point(x, -y)

Point negateP(Point P) {
  BigInt x = P.xParam;
  BigInt y = (P.yParam) * BigInt.from(-1);
  return Point(x, y);
}

// Generating Mikro U

int generateMikroU() {
  int mikroU;
  Random rnd = new Random();

  int next(int min, int max) => min + rnd.nextInt(max - min);
  mikroU = next(30, 50);

  return mikroU;
}

// Generate N

BigInt generateN() {
  BigInt n = randomX(getRandomBigInt());
  while (n.compareTo(calculateP() ~/ BigInt.from(mikroU)) >= 0) {
    n = randomX(getRandomBigInt());
  }
  return n;
}

// Encoding message

Point encode(BigInt message, int randomMikroU, BigInt n) {
  BigInt x;
  BigInt f;

  for (int j = 1; j <= randomMikroU; j++) {
    x = (message * BigInt.from(randomMikroU) + BigInt.from(j)) % calculateP();
    f = calcRightSide(x);
    if (isQuadraticResidue(f) && belongsToCurve(x, mySqrt(f))) {
      pM = Point(x, mySqrt(f));
      break;
    }
  }
  return pM;
}

// Decoding message

BigInt decode(Point pM, int randomMikroU) {
  BigInt decodedMessage;
  decodedMessage = (pM.xParam - BigInt.from(1)) ~/ BigInt.from(randomMikroU);
  return decodedMessage;
}

// Get random n parameter

BigInt randomN() {
  BigInt max =
      calculateP() + BigInt.one - (BigInt.two * bSqrt(calculateP() - BigInt.one));
  BigInt n = randomX(max);
  return n;
}

// nP calculation algorithm

Point nPAlgorithm(BigInt n, Point P) {
  Point Q = P;
  String bString = n.toRadixString(2);

  int k = bString.length;

  for (int j = k - 2; j >= 0; j--) {
    Q = sum2P(Q);
    if (bString[j] == "1") {
      Q = sumPQ(P, Q);
    }
  }
  return Q;
}

// Public key class

class PublicKey {
  BigInt p;
  Point P;
  Point Q;

  PublicKey(this.p, this.P, this.Q);
}

// Private key class

class PrivateKey {
  BigInt p;
  Point P;
  Point Q;
  BigInt x;

  PrivateKey(this.p, this.P, this.Q, this.x);
}

// Alice method generates keys and decrypt message

alice() {
  List<Point> pointsContainerFromBob = [];
  findRandomPoints(1);
  Point P = new Point(pointCollection[0].xParam, pointCollection[0].yParam);
  BigInt x = randomN();
  Point Q = nPAlgorithm(x, P);
  PublicKey publicKey = new PublicKey(calculateP(), P, Q);
  PrivateKey privateKey = new PrivateKey(calculateP(), P, Q, x);
  print(
      "Public key:\np = ${publicKey.p},\nP = ${publicKey.P},\nQ = ${publicKey.Q}\n");
  print(
      "Private key:\np = ${privateKey.p},\nP = ${privateKey.P},\nQ = ${privateKey.Q},\nx = ${privateKey.x}\n");

  pointsContainerFromBob = bob(publicKey, messageToEncode);

  print("-------------------------");
  print("Alice decrypts message:");
  print("-------------------------\n");

  Point C1 = Point(pointsContainerFromBob[0].xParam, pointsContainerFromBob[0].yParam);
  Point C2 = Point(pointsContainerFromBob[1].xParam, pointsContainerFromBob[1].yParam);
  Point pM = sumPQ(C2, negateP(nPAlgorithm(x, C1)));

  return print("Result of decoding: ${decode(pM, mikroU)}\n");

}

// Bob method encrypts message using public key

bob(PublicKey publicKey, BigInt message) {
  print("-------------------------");
  print("Bob encrypts message:");
  print("-------------------------\n");
  List<Point> pointsContainer = [];
  Point pM = encode(message, mikroU, nParam);
  print("Result of encoding: Pm = (x = ${pM.xParam}, y = ${pM.yParam})\n");
  BigInt y = randomN();
  print("Random y = $y \n");
  Point yQ = nPAlgorithm(y, publicKey.Q);
  print("yQ = $yQ \n");
  Point yP = nPAlgorithm(y, publicKey.P);
  print("yP = $yP \n");
  Point C1 = yP;
  Point C2 = sumPQ(pM, yQ);
  pointsContainer.add(C1);
  pointsContainer.add(C2);
  print(
      "Message encrypted by Bob:\n\nC1 = (x = ${C1.xParam}, y = ${C1.yParam})\nC2 = (x = ${C2.xParam}, y = ${C2.yParam})\n");

  return pointsContainer;
}
