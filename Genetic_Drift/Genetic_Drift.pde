/// Last Modified: September 30, 2020

/// Values you can change ///
int n = 10; 
int padding = 100;
int gapBetweenRings = 20; // Gap between adjacent square-shaped rings of cells
int frameRate = 7;


PFont f;
float cellSize;
String[][] cellsNow = new String[n][n]; 
String[][] cellsNext = new String[n][n];
String[] alleleChoices = {"A","a"}; // Genes that determine the cell's genotype 
                                    // The genotype determines if a cell is green or yellow
// "A" is the dominant allele while "a" is the recesive allele
// Each cell's genotype is a combination of two alleles (ex. "Aa", "aa", "AA")
// Genotypes with at least one "A" (dominant) allele produce a green cell (ex. "AA" or "Aa")
// Genotypes with two "a" (recessive) alleles produce yellow cell

int[] colour = new int[3]; // An array for the r,g, and b values of a cell
float[] cellSizeExtension = new float[round(n/2.0)]; // How much each cell's width or height
                                                    // needs to be extended by to acommodate 
                                                    // the gap between the rings

float  startingX, startingY, endingX,endingY; 
// startingX --> x value of the left side of a given square-shaped ring
// startingY --> y value of the top side of a given square-shaped ring
// endingX --> x value of the right side of a given square-shaped ring
// endingY --> y value of the bottom side of a given square-shaped ring




//// Fill grid with random genotypes ////
void setCellValuesRandomly() {
  for (int r=0; r<n; r++) {
    for (int c=0; c<n; c++) {
      //println("hi");
      String allele1 = alleleChoices[round(random(1))];
      String allele2 = alleleChoices[round(random(1))];
      
      cellsNow[r][c] = allele1 + allele2; 
    }
  }
}


int ringSpan; // Length/width of a square-shaped ring  

/// Calculates how much the width or height of each square cell needs to be extended by 
/// to accomodate the gap between the rings.
void computeCellSizeExtension(){
  if (n%2==0)
    ringSpan = 2;
  else
    ringSpan = 1;
  
  float extension = 0;
  
  for (int i=round(n/2.0)-1; i>=0; i--) {
   cellSizeExtension[i] = extension;
   ringSpan+=2;
   extension = ( (ringSpan-3)*cellSizeExtension[i] + 2*gapBetweenRings ) / float(ringSpan-1); 
   /// ^ a formula for calculating how much each cell needs to be extended by
  } 
}


void setup () {
  
 size(800,800);
 frameRate(frameRate);
 f = createFont("Cambria",25);
 textFont(f);
 
 computeCellSizeExtension();
 cellSize = (float) (height-2*padding-(n-1)*cellSizeExtension[0])/n;
 setCellValuesRandomly();
   
 background(166,140,99);

 fill(0);
 text("Each square-shaped ring represents an isolated colony of organisms",12,30);
 text("One cell = One organism",12,60);
 text("AA or Aa genotype = Green", 12,height-45);
 text("aa genotype = Yellow", 12, height-15);
}

void draw() {

  stroke(166,140,99);
  
  int startingRow = 0;
  int startingCol = 0;
  int ringSize = n;
  
  
  for (int i=0; i<round(n/2.0); i++) { // For each square-shaped ring on the grid
    
    if (i==0) {
      startingX = cellSize*startingCol + padding;
      startingY = cellSize*startingRow + padding;
      endingX =  startingX + (ringSize-1)*(cellSize+cellSizeExtension[i]);
      endingY = startingY + (ringSize-1)*(cellSize+cellSizeExtension[i]);
        
      }
    else {
      startingX =  (cellSize+gapBetweenRings)*startingCol + padding;
      startingY = (cellSize+gapBetweenRings)*startingRow + padding;
      endingX = startingX + (ringSize-1)*(cellSize+cellSizeExtension[i]);
      endingY = startingY + (ringSize-1)*(cellSize+cellSizeExtension[i]);
    }
    
    if (ringSize>1) {
        
      // Fills in the cell colours of the top side of the ring, from left to right
      for (int j=startingCol; j<(startingCol+ringSize-1); j++) {
        float x = startingX + (cellSize+cellSizeExtension[i])*(j-startingCol);
        float y = startingY;
        colour = getColour(cellsNow[startingRow][j]);
        fill(colour[0],colour[1],colour[2]);
        rect(x,y,cellSize+cellSizeExtension[i],cellSize);
        
        
        // Computes the offspring of the current cell and the next (clockwise) cell in the ring
        String parent1 = cellsNow[startingRow][j];
        String parent2 = cellsNow[startingRow][j+1];
        cellsNext[startingRow][j] =  computeOffspring(parent1,parent2);
       
       // Assigns the offspring cells a random spot (aka index) inside the ring
        if (j==startingCol+ringSize-2)
          shuffleNextGen(startingCol,startingCol+ringSize-1,startingRow,"Row");
      }
      
      // Fills in the cell colours of the right side of the ring, from top to bottom
      for (int k=startingRow; k<(startingRow+ringSize-1); k++) {
        float x = endingX;
        float y = startingY + (cellSize+cellSizeExtension[i])*(k-startingRow);
        colour = getColour(cellsNow[k][startingCol+ringSize-1]);
        fill(colour[0],colour[1],colour[2]);
        rect(x,y,cellSize,cellSize+cellSizeExtension[i]);

        String parent1 = cellsNow[k][startingCol+ringSize-1];
        String parent2 = cellsNow[k+1][startingCol+ringSize-1];
        cellsNext[k][startingCol+ringSize-1] = computeOffspring(parent1,parent2);
        //println(parent1,parent2,i,ringSize);
        
        if (k==startingRow+ringSize-2)
          shuffleNextGen(startingRow,startingRow+ringSize-1,startingCol+ringSize-1,"Col");
          
      }
      
      // Fills in the cell colours of the bottom side of the ring, from right to left
      for (int  l=startingCol+ringSize-1; l>startingCol; l--) {
        float x = endingX - (cellSize+cellSizeExtension[i])*(startingCol+ringSize-1-l);
        float y = endingY;
        colour = getColour(cellsNow[startingRow+ringSize-1][l]);   
        fill(colour[0],colour[1],colour[2]);
        rect(x-cellSizeExtension[i],y,cellSize+cellSizeExtension[i],cellSize);

        
        String parent1 = cellsNow[startingRow+ringSize-1][l];
        String parent2 = cellsNow[startingRow+ringSize-1][l-1];
        cellsNext[startingRow+ringSize-1][l] = computeOffspring(parent1,parent2);
        
        if (l==startingCol+1)
          shuffleNextGen(startingCol+1,startingCol+ringSize,startingRow+ringSize-1,"Row");
  
      }
      
      // Fills in the cell colours of the left side of the ring, from bottom to top
      for (int m=startingRow+ringSize-1; m>startingRow; m--) {
        float x = startingX;
        float y = endingY  - (cellSize+cellSizeExtension[i])*(startingRow+ringSize-1-m);
        colour = getColour(cellsNow[m][startingCol]);        
        fill(colour[0],colour[1],colour[2]);
        rect(x,y-cellSizeExtension[i],cellSize,cellSize+cellSizeExtension[i]);

        
        String parent1 = cellsNow[m][startingCol];
        String parent2 = cellsNow[m-1][startingCol];
        cellsNext[m][startingCol] = computeOffspring(parent1,parent2);

        if (m==startingRow+1)
          shuffleNextGen(startingRow+1,startingRow+ringSize,startingCol,"Col");               
           
      }
    
    }
    
    else {
      float x = startingX;
      float y = startingY;
      colour = getColour(cellsNow[startingRow][startingCol]);
      fill(196);
      rect(x,y,cellSize,cellSize);
      
      cellsNext[startingRow][startingCol] = cellsNow[startingRow][startingCol]; 
    }
    
    
    
    startingRow += 1;
    startingCol+=1;
    ringSize -= 2;

    }
    
    /// Overwrites current generation with its offspring
    for (int r=0; r<n; r++) {
      for (int c=0; c<n; c++) {
        cellsNow[r][c] = cellsNext[r][c]; 
      }
    }
  if (frameCount==2)
    delay(1000);
  }

 
 
/// Computes the cells colour based on its genotype ///
int[] getColour(String genotype) {
  int[] colour = new int[3];

  
  if (genotype.indexOf("A")==-1) {
    //Yellow
    colour[0] = 238;
    colour[1] = 225;
    colour[2] = 32;
  }
  else{
    //Green
    colour[0] = 80;
    colour[1] = 186;
    colour[2] = 46;
  }
  return colour;
}


/// Assigns each offspring cell a random spot (index) inside the colony ///

void shuffleNextGen(int startingIndex, int endingIndex, int constantIndex, String isRowOrColumnConstant ) {
  int r,c;
  for (int i=startingIndex; i<endingIndex; i++) {
     int x = round(random(startingIndex,endingIndex-1));

    if (isRowOrColumnConstant == "Row") {
      r = constantIndex;
      c = i;

    }
    else  {
      r = i;
      c = constantIndex;
    }
    
    String currentCell = cellsNext[r][c];
    
    if (isRowOrColumnConstant == "Row") {
      cellsNext[r][c] = cellsNext[r][x];
      cellsNext[r][x] = currentCell;
    }
    else {
     cellsNext[r][c] = cellsNext[x][c];
     cellsNext[x][c] = currentCell;

    }
     
  }  
}


/// Computes the offspring cell's genotype ///
String computeOffspring(String p1, String p2) {
  String[] possibilities = computePossibilities(p1,p2);
  String offspring = possibilities[ round(random(3)) ];
  
  return offspring;
}


/// Computes the possible genotypes that can be produced
String[] computePossibilities(String p1, String p2) {
  String[] listP1 = p1.split("");
  String[] listP2 = p2.split("");
  
  String[] possibilities = new String[4];
  
  possibilities[0] = listP1[0] + listP2[0];
  possibilities[1] = listP1[0] + listP2[1];
  possibilities[2] = listP1[1] + listP2[0];
  possibilities[3] = listP1[1] + listP2[1];
  
  return possibilities;
}
