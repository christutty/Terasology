/*
 * Copyright 2012
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.terasology.physics;

import javax.vecmath.Vector3f;

import org.terasology.math.Vector3i;
import org.terasology.world.WorldProvider;
import org.terasology.world.block.Block;

import com.bulletphysics.collision.shapes.CollisionShape;
import com.bulletphysics.collision.shapes.voxel.VoxelInfo;
import com.bulletphysics.collision.shapes.voxel.VoxelPhysicsWorld;

/**
 * @author Immortius
 */
public class PhysicsWorldWrapper implements VoxelPhysicsWorld {

    private WorldProvider world;

    public PhysicsWorldWrapper(WorldProvider world) {
        this.world = world;
    }

    @Override
    public VoxelInfo getCollisionShapeAt(int x, int y, int z) {
        Block block = world.getBlock(x, y, z);
        return new TeraVoxelInfo(block, block.isTargetable(), !block.isPenetrable(), new Vector3i(x, y, z));
    }

    private static class TeraVoxelInfo implements VoxelInfo {

        private boolean colliding;
        private boolean blocking;
        private CollisionShape shape;
        private Vector3i position;
        private Vector3f offset;

        public TeraVoxelInfo(Block block, boolean colliding, boolean blocking, Vector3i position) {
            this.shape = block.getCollisionShape();
            this.offset = block.getCollisionOffset();
            this.colliding = shape != null && colliding;
            this.blocking = shape != null && blocking;
            this.position = position;
        }

        @Override
        public boolean isColliding() {
            return colliding;
        }

        @Override
        public Object getUserData() {
            return position;
        }

        @Override
        public CollisionShape getCollisionShape() {
            return shape;
        }

        @Override
        public Vector3f getCollisionOffset() {
            return offset;
        }

        @Override
        public boolean isBlocking() {
            return blocking;
        }
    }
}
