#pragma once

enum class ServiceLifecycle {
    Created,
    Initializing,
    Ready,
    Failed,
    ShuttingDown
};
