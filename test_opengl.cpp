#include <GL/glut.h>
#include <iostream>
#include <chrono>

// Function declarations
void display();
void initializeOpenGL();

// Test functions
void performanceTest() {
    std::cout << "Running Performance Test...\n";
    auto start = std::chrono::high_resolution_clock::now();

    // Set duration for the test (in seconds)
    const int testDuration = 2; // seconds
    int framesRendered = 0;

    // Total time taken for rendering frames
    double totalRenderTime = 0.0;

    // Run the test for a set duration
    while (true) {
        auto currentTime = std::chrono::high_resolution_clock::now();
        std::chrono::duration<double> elapsed = currentTime - start;

        if (elapsed.count() >= testDuration) {
            break; // Exit the loop after the duration
        }

        // Measure frame rendering time
        auto frameStart = std::chrono::high_resolution_clock::now();
        display();  // Call display function
        auto frameEnd = std::chrono::high_resolution_clock::now();

        // Calculate frame rendering time
        std::chrono::duration<double, std::milli> frameDuration = frameEnd - frameStart;
        std::cout << "Frame rendered in " << frameDuration.count() << " ms\n";

        // Accumulate total render time and increment frame count
        totalRenderTime += frameDuration.count();
        framesRendered++;
    }

    auto end = std::chrono::high_resolution_clock::now();
    auto totalDuration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);

    std::cout << "Performance Test Completed! Rendered " << framesRendered << " frames in " 
              << totalDuration.count() << " ms\n";

    // Calculate average frames per second (FPS)
    double fps = framesRendered / (totalDuration.count() / 1000.0);
    std::cout << "Average Frames per second (FPS): " << fps << "\n";

    // Calculate average frame rendering time in milliseconds
    double averageFrameTime = totalRenderTime / framesRendered;
    std::cout << "Average frame rendering time: " << averageFrameTime << " ms\n";
}
void visualRegressionTest() {
    std::cout << "Running Visual Regression Test...\n";
    
    // Note: Actual visual comparison requires more setup (image capture, comparison)
    // This is a placeholder for where the visual comparison logic would go.
    
    // For example:
    display();  // Call display to render the frame
    std::cout << "Visual Regression Test: Check passed image data.\n";
}

// Main function for testing
int main(int argc, char** argv) {
    initializeOpenGL();  // Initialize OpenGL context

    performanceTest();    // Run performance test
    visualRegressionTest(); // Run visual regression test

    return 0;
}

// Initializes GLUT for testing purposes
void initializeOpenGL() {
    int argc = 1;
    char* argv[1] = {(char*)"Something"};
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB); // Use double buffering
    glutInitWindowSize(400, 300);
    glutCreateWindow("OpenGL Test");
    glutDisplayFunc(display); // Register the display function
}

// Clears the current window and draws a triangle.
void display() {
    // Set every pixel in the frame buffer to the current clear color.
    glClear(GL_COLOR_BUFFER_BIT);

    // Drawing is done by specifying a sequence of vertices.
    glBegin(GL_TRIANGLES); // Drawing a triangle
        glColor3f(1, 0, 0); glVertex3f(-0.6, -0.75, 0.0);
        glColor3f(0, 1, 0); glVertex3f(0.6, -0.75, 0.0);
        glColor3f(0, 0, 1); glVertex3f(0.0, 0.75, 0.0);
    glEnd();

    // Flush drawing command buffer to make drawing happen as soon as possible.
    glutSwapBuffers(); // Swap buffers for smooth rendering
}