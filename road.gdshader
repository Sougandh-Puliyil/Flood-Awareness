shader_type canvas_item;

void vertex() {

    float wave = sin(VERTEX.x * 0.05 + TIME * 2.0) * 6.0;

    if (UV.y < 0.1) {
        VERTEX.y += wave;
    }
}