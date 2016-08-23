#include "system.hpp"
#include "control.hpp"
#include "math.hpp"
#include "main.hpp"

#include <iostream>

#include "omp.h"
#include <boost/asio.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>

int main(int argc, const char **argv) {
	glfwInit();
	std::atomic_bool alive(true);
	Control::control ctl(alive, "share/bunny.ply",
			"share/shade.vert", "share/shade.frag");
	Util::task::init(alive, &ctl);
	Util::task::run(alive, &ctl);
	return 0;
}
